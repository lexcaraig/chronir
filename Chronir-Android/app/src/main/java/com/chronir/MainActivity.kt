package com.chronir

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Alarm
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Alarm
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.chronir.data.repository.SettingsRepository
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.theme.LocalChronirHapticsEnabled
import com.chronir.feature.alarmcreation.AlarmCreationScreen
import com.chronir.feature.alarmdetail.AlarmDetailScreen
import com.chronir.feature.alarmlist.AlarmListScreen
import com.chronir.feature.alarmlist.AlarmListViewModel
import com.chronir.feature.paywall.PaywallScreen
import com.chronir.feature.settings.CompletionHistoryScreen
import com.chronir.feature.settings.HowAlarmsWorkScreen
import com.chronir.feature.settings.LegalDocumentScreen
import com.chronir.feature.settings.SettingsScreen
import com.chronir.feature.settings.SubscriptionScreen
import com.chronir.model.ThemePreference
import com.chronir.services.BillingService
import com.chronir.services.OverdueAlarmChecker
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed class Screen(
    val route: String,
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
) {
    data object AlarmList : Screen(
        route = "alarm_list",
        label = "Alarms",
        selectedIcon = Icons.Filled.Alarm,
        unselectedIcon = Icons.Outlined.Alarm
    )

    data object Settings : Screen(
        route = "settings",
        label = "Settings",
        selectedIcon = Icons.Filled.Settings,
        unselectedIcon = Icons.Outlined.Settings
    )
}

private val screens = listOf(Screen.AlarmList, Screen.Settings)

// Platform default 3-button-navigation scrims (same values enableEdgeToEdge() uses by default).
private val NavBarLightScrim = Color.argb(0xE6, 0xFF, 0xFF, 0xFF)
private val NavBarDarkScrim = Color.argb(0x80, 0x1B, 0x1B, 0x1B)

private const val ROUTE_ALARM_CREATION = "alarm_creation"
private const val ROUTE_ALARM_DETAIL = "alarm_detail/{alarmId}"
private const val ROUTE_COMPLETION_HISTORY = "completion_history"
private const val ROUTE_SUBSCRIPTION = "subscription"
private const val ROUTE_PAYWALL = "paywall"
private const val ROUTE_HOW_ALARMS_WORK = "how_alarms_work"
private const val ROUTE_LEGAL = "legal/{title}/{encodedUrl}"

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    @Inject
    lateinit var billingService: BillingService

    @Inject
    lateinit var overdueAlarmChecker: OverdueAlarmChecker

    private val deepLinkAlarmId = mutableStateOf<String?>(null)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        billingService.initialize()
        handleDeepLink(intent)
        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                billingService.destroy()
            }

            override fun onResume(owner: androidx.lifecycle.LifecycleOwner) {
                val activity = this@MainActivity
                kotlinx.coroutines.MainScope().launch {
                    val overdue = overdueAlarmChecker.findFirstOverdueAlarm()
                    if (overdue != null) {
                        val firingIntent = Intent().apply {
                            setClassName(activity.packageName, "com.chronir.feature.alarmfiring.AlarmFiringActivity")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                            putExtra("extra_alarm_id", overdue.id)
                        }
                        activity.startActivity(firingIntent)
                    }
                }
            }
        })
        setContent {
            val settings by settingsRepository.settings.collectAsStateWithLifecycle(
                initialValue = com.chronir.data.repository.UserSettings()
            )

            val darkTheme = when (settings.themePreference) {
                ThemePreference.LIGHT -> false
                ThemePreference.DARK -> true
                ThemePreference.DYNAMIC -> null
            }

            val useDarkTheme = darkTheme ?: isSystemInDarkTheme()

            // Status/navigation bar icons follow the app's resolved theme, not the system night mode.
            DisposableEffect(useDarkTheme) {
                enableEdgeToEdge(
                    statusBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT) { useDarkTheme },
                    navigationBarStyle = SystemBarStyle.auto(NavBarLightScrim, NavBarDarkScrim) { useDarkTheme }
                )
                onDispose {}
            }

            ChronirTheme(
                darkTheme = useDarkTheme,
                dynamicColor = settings.themePreference == ThemePreference.DYNAMIC,
                textScale = settings.textSizePreference.scaleFactor
            ) {
                CompositionLocalProvider(LocalChronirHapticsEnabled provides settings.hapticFeedbackEnabled) {
                    if (!settings.hasCompletedOnboarding) {
                        val scope = rememberCoroutineScope()
                        OnboardingScreen(
                            onComplete = {
                                scope.launch {
                                    settingsRepository.setHasCompletedOnboarding(true)
                                }
                            }
                        )
                    } else {
                        ChronirNavigation(deepLinkAlarmId = deepLinkAlarmId.value) {
                            deepLinkAlarmId.value = null
                        }
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?) {
        val data = intent?.data ?: return
        if (data.scheme == "chronir" && data.host == "alarm") {
            val alarmId = data.pathSegments?.firstOrNull()
            // SEC-05: only well-formed alarm IDs (UUIDs) are acted on.
            if (alarmId != null && runCatching { java.util.UUID.fromString(alarmId) }.isSuccess) {
                deepLinkAlarmId.value = alarmId
            }
        }
    }
}

@Composable
private fun ChronirNavigation(
    deepLinkAlarmId: String? = null,
    onDeepLinkConsumed: () -> Unit = {}
) {
    val navController = rememberNavController()
    // Same Free-tier check the list's + button uses, so the form never opens when it can't be saved.
    val canCreateAlarm by hiltViewModel<AlarmListViewModel>().canCreateAlarm.collectAsStateWithLifecycle()

    LaunchedEffect(deepLinkAlarmId) {
        if (deepLinkAlarmId != null) {
            navController.navigate("alarm_detail/$deepLinkAlarmId") {
                launchSingleTop = true
            }
            onDeepLinkConsumed()
        }
    }

    // Each screen's own Scaffold/TopAppBar applies the status-bar inset. This outer Scaffold only
    // reserves the bottom bar, and consumes that space so inner screens don't pad it again.
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        contentWindowInsets = WindowInsets(0),
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentDestination = navBackStackEntry?.destination
            val currentRoute = currentDestination?.route

            val hideBottomBar = currentRoute == ROUTE_ALARM_CREATION ||
                currentRoute == ROUTE_ALARM_DETAIL ||
                currentRoute == ROUTE_COMPLETION_HISTORY ||
                currentRoute == ROUTE_SUBSCRIPTION ||
                currentRoute == ROUTE_PAYWALL ||
                currentRoute == ROUTE_HOW_ALARMS_WORK ||
                currentRoute == ROUTE_LEGAL
            if (!hideBottomBar) {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface,
                    contentColor = MaterialTheme.colorScheme.onSurface
                ) {
                    screens.forEachIndexed { index, screen ->
                        if (index == 1) {
                            NavigationBarItem(
                                icon = { Icon(imageVector = Icons.Filled.Add, contentDescription = null) },
                                label = { Text("New") },
                                selected = false,
                                colors = NavigationBarItemDefaults.colors(
                                    unselectedIconColor = MaterialTheme.colorScheme.primary,
                                    unselectedTextColor = MaterialTheme.colorScheme.primary
                                ),
                                modifier = Modifier.semantics { contentDescription = "Create alarm" },
                                onClick = {
                                    navController.navigate(if (canCreateAlarm) ROUTE_ALARM_CREATION else ROUTE_PAYWALL)
                                }
                            )
                        }
                        val selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true
                        NavigationBarItem(
                            icon = {
                                Icon(
                                    imageVector = if (selected) screen.selectedIcon else screen.unselectedIcon,
                                    contentDescription = screen.label
                                )
                            },
                            label = { Text(screen.label) },
                            selected = selected,
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = MaterialTheme.colorScheme.onSurface,
                                selectedTextColor = MaterialTheme.colorScheme.onSurface,
                                unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                                unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant,
                                indicatorColor = MaterialTheme.colorScheme.surfaceVariant
                            ),
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.AlarmList.route,
            modifier = Modifier
                .padding(innerPadding)
                .consumeWindowInsets(innerPadding)
        ) {
            composable(Screen.AlarmList.route) {
                AlarmListScreen(
                    onNavigateToCreation = {
                        navController.navigate(ROUTE_ALARM_CREATION)
                    },
                    onNavigateToDetail = { alarmId ->
                        navController.navigate("alarm_detail/$alarmId")
                    },
                    onNavigateToPaywall = { navController.navigate(ROUTE_PAYWALL) }
                )
            }
            composable(Screen.Settings.route) {
                SettingsScreen(
                    onNavigateToHistory = {
                        navController.navigate(ROUTE_COMPLETION_HISTORY)
                    },
                    onNavigateToSubscription = {
                        navController.navigate(ROUTE_SUBSCRIPTION)
                    },
                    onNavigateToLegal = { title, url ->
                        val encodedUrl = java.net.URLEncoder.encode(url, "UTF-8")
                        navController.navigate("legal/$title/$encodedUrl")
                    },
                    onNavigateToHowAlarmsWork = {
                        navController.navigate(ROUTE_HOW_ALARMS_WORK)
                    }
                )
            }
            composable(ROUTE_ALARM_CREATION) {
                AlarmCreationScreen(
                    onDismiss = { navController.popBackStack() },
                    onNavigateToPaywall = { navController.navigate(ROUTE_PAYWALL) }
                )
            }
            composable(
                route = ROUTE_ALARM_DETAIL,
                arguments = listOf(navArgument("alarmId") { type = NavType.StringType })
            ) {
                AlarmDetailScreen(
                    onDismiss = { navController.popBackStack() },
                    onNavigateToPaywall = { navController.navigate(ROUTE_PAYWALL) }
                )
            }
            composable(ROUTE_COMPLETION_HISTORY) {
                CompletionHistoryScreen(
                    onBack = { navController.popBackStack() }
                )
            }
            composable(ROUTE_SUBSCRIPTION) {
                SubscriptionScreen(
                    onBack = { navController.popBackStack() },
                    onNavigateToPaywall = {
                        navController.navigate(ROUTE_PAYWALL)
                    }
                )
            }
            composable(ROUTE_HOW_ALARMS_WORK) {
                HowAlarmsWorkScreen(
                    onBack = { navController.popBackStack() }
                )
            }
            composable(ROUTE_PAYWALL) {
                PaywallScreen(
                    onDismiss = { navController.popBackStack() }
                )
            }
            composable(
                route = ROUTE_LEGAL,
                arguments = listOf(
                    navArgument("title") { type = NavType.StringType },
                    navArgument("encodedUrl") { type = NavType.StringType }
                )
            ) { backStackEntry ->
                val title = backStackEntry.arguments?.getString("title") ?: ""
                val encodedUrl = backStackEntry.arguments?.getString("encodedUrl") ?: ""
                val url = java.net.URLDecoder.decode(encodedUrl, "UTF-8")
                LegalDocumentScreen(
                    title = title,
                    url = url,
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}
