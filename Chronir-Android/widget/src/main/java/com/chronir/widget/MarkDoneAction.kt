package com.chronir.widget

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.chronir.services.AlarmCompletionService
import kotlinx.coroutines.delay

/**
 * Widget check button: completes the alarm's upcoming occurrence and schedules the next one, then
 * shows "Marked {title} done" on the tapped widget for a moment so the tap is visibly acknowledged.
 * (Glance has no transient UI or snackbar, and an undo would need to reverse a completion record and
 * a reschedule, so there is no undo here; the alarm stays editable in the app.)
 */
class MarkDoneAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val alarmId = parameters[AlarmIdKey] ?: return
        val entryPoint = widgetEntryPoint(context)
        val title = entryPoint.alarmRepository().getAlarmById(alarmId)?.title
        val result = entryPoint.alarmCompletionService()
            .completeUpcoming(alarmId, expectedFireDateMillis = parameters[ExpectedFireDateKey])

        if (result == AlarmCompletionService.Result.COMPLETED && title != null) {
            updateAppWidgetState(context, glanceId) { it[JustCompletedTitleKey] = title }
            updateAllChronirWidgets(context)
            delay(CONFIRMATION_MS)
            updateAppWidgetState(context, glanceId) { it.remove(JustCompletedTitleKey) }
        }
        updateAllChronirWidgets(context)
    }

    companion object {
        val AlarmIdKey = ActionParameters.Key<String>("alarmId")
        val ExpectedFireDateKey = ActionParameters.Key<Long>("expectedFireDate")
        private const val CONFIRMATION_MS = 2_500L
    }
}
