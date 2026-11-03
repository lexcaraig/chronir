package com.chronir.feature.alarmcreation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.AlarmRepository
import com.chronir.model.Alarm
import com.chronir.model.AlarmTemplate
import com.chronir.services.AlarmScheduler
import com.chronir.services.BillingService
import com.chronir.services.DateCalculator
import com.chronir.services.SubscriptionTier
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import javax.inject.Inject

/** A save problem shown as a snackbar; [offerUpgrade] adds an "Upgrade" action to the paywall. */
data class EditorMessage(
    val text: String,
    val offerUpgrade: Boolean = false
)

data class AlarmCreationUiState(
    val form: AlarmFormState = AlarmFormState(),
    val isPlusTier: Boolean = false,
    val isSaving: Boolean = false,
    val saveSuccess: Boolean = false,
    val titleError: String? = null,
    val message: EditorMessage? = null
)

@HiltViewModel
class AlarmCreationViewModel
    @Inject
    constructor(
        private val alarmRepository: AlarmRepository,
        private val dateCalculator: DateCalculator,
        private val alarmScheduler: AlarmScheduler,
        private val billingService: BillingService
    ) : ViewModel() {

        companion object {
            const val FREE_TIER_ALARM_LIMIT = 3
            const val TITLE_REQUIRED = "Enter a name for this alarm."
            const val FREE_LIMIT_MESSAGE = "Free includes $FREE_TIER_ALARM_LIMIT alarms. Upgrade to Plus for unlimited alarms."
        }

        private val _uiState = MutableStateFlow(AlarmCreationUiState())
        val uiState: StateFlow<AlarmCreationUiState> = _uiState.asStateFlow()

        private val isPlusTier: Boolean
            get() = billingService.subscriptionState.value.tier != SubscriptionTier.FREE

        init {
            viewModelScope.launch {
                billingService.subscriptionState.collect { state ->
                    _uiState.update { it.copy(isPlusTier = state.tier != SubscriptionTier.FREE) }
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
                val clearsTitleError = event is AlarmFormEvent.TitleChanged || event is AlarmFormEvent.TemplateLoaded
                state.copy(
                    form = state.form.reduce(event, plus),
                    titleError = if (clearsTitleError) null else state.titleError
                )
            }
        }

        fun loadTemplate(template: AlarmTemplate) = onFormEvent(AlarmFormEvent.TemplateLoaded(template))

        fun messageShown() {
            _uiState.update { it.copy(message = null) }
        }

        fun saveAlarm() {
            val form = _uiState.value.form
            if (form.title.isBlank()) {
                _uiState.update { it.copy(titleError = TITLE_REQUIRED, message = EditorMessage(TITLE_REQUIRED)) }
                return
            }

            _uiState.update { it.copy(isSaving = true, titleError = null, message = null) }

            viewModelScope.launch {
                try {
                    // Free tier: 3-alarm limit (also checked before the form opens; this is the enforcing gate).
                    if (!isPlusTier && alarmRepository.observeAlarms().first().size >= FREE_TIER_ALARM_LIMIT) {
                        _uiState.update {
                            it.copy(isSaving = false, message = EditorMessage(FREE_LIMIT_MESSAGE, offerUpgrade = true))
                        }
                        return@launch
                    }

                    val alarm = form.applyTo(Alarm(title = form.title.trim()))
                    val alarmWithFireDate = alarm.copy(
                        nextFireDate = dateCalculator.calculateNextFireDate(alarm, Instant.now())
                    )

                    alarmRepository.saveAlarm(alarmWithFireDate)
                    // The alarm is saved at this point: a scheduling failure must not keep the screen open,
                    // or every retry tap saves a duplicate (BUG-04). Reschedule/boot paths register it later.
                    runCatching { alarmScheduler.schedule(alarmWithFireDate) }

                    _uiState.update { it.copy(isSaving = false, saveSuccess = true) }
                } catch (e: Exception) {
                    _uiState.update {
                        it.copy(isSaving = false, message = EditorMessage("Couldn't save the alarm. Try again."))
                    }
                }
            }
        }
    }
