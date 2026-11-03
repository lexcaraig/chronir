package com.chronir.feature.alarmdetail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.data.repository.CompletionRepository
import com.chronir.feature.alarmcreation.AlarmCreationViewModel
import com.chronir.feature.alarmcreation.AlarmFormEvent
import com.chronir.feature.alarmcreation.AlarmFormState
import com.chronir.feature.alarmcreation.EditorMessage
import com.chronir.feature.alarmcreation.reduce
import com.chronir.feature.alarmcreation.requiresPlus
import com.chronir.model.Alarm
import com.chronir.model.CompletionAction
import com.chronir.model.CompletionRecord
import com.chronir.services.AlarmScheduler
import com.chronir.services.BillingService
import com.chronir.services.DateCalculator
import com.chronir.services.NotificationCleanupService
import com.chronir.services.PendingConfirmationService
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import javax.inject.Inject

data class AlarmDetailUiState(
    val isLoading: Boolean = true,
    val notFound: Boolean = false,
    val form: AlarmFormState = AlarmFormState(),
    val isEnabled: Boolean = true,
    val isPendingConfirmation: Boolean = false,
    val isPlusTier: Boolean = false,
    val isSaving: Boolean = false,
    val saveSuccess: Boolean = false,
    val titleError: String? = null,
    val message: EditorMessage? = null,
    val completionHistory: List<CompletionRecord> = emptyList(),
    val completionCount: Int = 0
)

@HiltViewModel
class AlarmDetailViewModel
    @Inject
    constructor(
        savedStateHandle: SavedStateHandle,
        private val alarmRepository: AlarmRepository,
        private val completionRepository: CompletionRepository,
        private val dateCalculator: DateCalculator,
        private val alarmScheduler: AlarmScheduler,
        private val notificationCleanupService: NotificationCleanupService,
        private val pendingConfirmationService: PendingConfirmationService,
        private val billingService: BillingService
    ) : ViewModel() {

        private val alarmId: String = checkNotNull(savedStateHandle["alarmId"])

        /** The stored alarm; the form is applied onto it so fields the form doesn't edit survive a save. */
        private var storedAlarm: Alarm? = null

        private val _uiState = MutableStateFlow(AlarmDetailUiState())
        val uiState: StateFlow<AlarmDetailUiState> = _uiState.asStateFlow()

        private val isPlusTier: Boolean
            get() = billingService.subscriptionState.value.tier != SubscriptionTier.FREE

        init {
            loadAlarm()
            loadCompletionHistory()
            viewModelScope.launch {
                billingService.subscriptionState.collect { state ->
                    _uiState.update { it.copy(isPlusTier = state.tier != SubscriptionTier.FREE) }
                }
            }
        }

        private fun loadAlarm() {
            viewModelScope.launch {
                val alarm = alarmRepository.getAlarmById(alarmId)
                if (alarm == null) {
                    _uiState.update { it.copy(isLoading = false, notFound = true) }
                    return@launch
                }
                storedAlarm = alarm
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        form = AlarmFormState.fromAlarm(alarm),
                        isEnabled = alarm.isEnabled,
                        isPendingConfirmation = alarm.isPendingConfirmation
                    )
                }
            }
        }

        private fun loadCompletionHistory() {
            viewModelScope.launch {
                completionRepository.observeByAlarmId(alarmId).collect { records ->
                    _uiState.update {
                        it.copy(
                            completionHistory = records,
                            completionCount = records.count { r -> r.action == CompletionAction.COMPLETED }
                        )
                    }
                }
            }
        }

        fun onFormEvent(event: AlarmFormEvent) {
            val plus = isPlusTier
            if (event.requiresPlus(plus)) {
                _uiState.update {
                    it.copy(message = EditorMessage("This option is part of Plus.", offerUpgrade = true))
                }
                return
            }
            _uiState.update { state ->
                state.copy(
                    form = state.form.reduce(event, plus),
                    titleError = if (event is AlarmFormEvent.TitleChanged) null else state.titleError
                )
            }
        }

        fun toggleEnabled(enabled: Boolean) {
            _uiState.update { it.copy(isEnabled = enabled) }
        }

        fun messageShown() {
            _uiState.update { it.copy(message = null) }
        }

        /** Records the pending occurrence as done through the same path as the firing flow. */
        fun confirmPending() {
            val alarm = storedAlarm ?: return
            viewModelScope.launch {
                pendingConfirmationService.confirmDone(alarm)
                storedAlarm = alarm.copy(isPendingConfirmation = false, pendingSince = null)
                _uiState.update {
                    it.copy(isPendingConfirmation = false, message = EditorMessage("Marked as done."))
                }
            }
        }

        fun saveAlarm() {
            val state = _uiState.value
            val base = storedAlarm ?: return
            if (state.form.title.isBlank()) {
                val error = AlarmCreationViewModel.TITLE_REQUIRED
                _uiState.update { it.copy(titleError = error, message = EditorMessage(error)) }
                return
            }

            _uiState.update { it.copy(isSaving = true, titleError = null, message = null) }

            viewModelScope.launch {
                try {
                    // Editing resets snooze and pending state, as it always has; everything else not
                    // shown in the form (createdAt, timezone, sync state, lastFiredDate) is preserved.
                    val alarm = state.form.applyTo(base).copy(
                        isEnabled = state.isEnabled,
                        snoozeCount = 0,
                        isPendingConfirmation = false,
                        pendingSince = null,
                        updatedAt = Instant.now()
                    )
                    val alarmWithFireDate = alarm.copy(
                        nextFireDate = dateCalculator.calculateNextFireDate(alarm, Instant.now())
                    )

                    alarmRepository.updateAlarm(alarmWithFireDate)

                    if (state.isEnabled) {
                        alarmScheduler.schedule(alarmWithFireDate)
                    } else {
                        alarmScheduler.cancel(alarmId)
                        notificationCleanupService.cancelAlarmNotifications(alarmId)
                    }

                    _uiState.update { it.copy(isSaving = false, saveSuccess = true) }
                } catch (e: Exception) {
                    _uiState.update {
                        it.copy(isSaving = false, message = EditorMessage("Couldn't save the alarm. Try again."))
                    }
                }
            }
        }

        fun deleteAlarm() {
            viewModelScope.launch {
                alarmScheduler.cancel(alarmId)
                notificationCleanupService.cancelAlarmNotifications(alarmId)
                completionRepository.deleteByAlarmId(alarmId)
                alarmRepository.deleteAlarm(alarmId)
                _uiState.update { it.copy(saveSuccess = true) }
            }
        }
    }
