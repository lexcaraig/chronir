package com.chronir

import android.app.Application
import com.chronir.data.repository.AlarmRepository
import com.chronir.services.AlarmLimitEnforcer
import com.chronir.services.BillingService
import com.chronir.widget.updateAllChronirWidgets
import dagger.hilt.android.HiltAndroidApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.conflate
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltAndroidApp
class ChronirApp : Application() {
    @Inject lateinit var alarmRepository: AlarmRepository

    @Inject lateinit var billingService: BillingService

    @Inject lateinit var alarmLimitEnforcer: AlarmLimitEnforcer

    private val appScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    override fun onCreate() {
        super.onCreate()
        // One place that sees every alarm write (create/edit/complete/delete/sync), so widgets never go stale.
        appScope.launch {
            alarmRepository.observeAlarms()
                .distinctUntilChanged()
                .drop(1) // initial emission: widgets render fresh on their own first update
                .conflate() // a burst of writes (reschedule, sync) refreshes widgets once, not once per row
                .collect { runCatching { updateAllChronirWidgets(this@ChronirApp) } }
        }
        // Free limit follows the tier: a lapsed Plus turns off the newest extra alarms, a new Plus restores them.
        appScope.launch { alarmLimitEnforcer.observe(billingService.subscriptionState) }
    }
}
