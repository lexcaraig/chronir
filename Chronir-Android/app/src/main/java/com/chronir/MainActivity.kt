package com.chronir

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
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
import com.chronir.feature.alarmcreation.AlarmCreationScreen
import com.chronir.feature.alarmdetail.AlarmDetailScreen
import com.chronir.feature.alarmlist.AlarmListScreen
import com.chronir.feature.alarmlist.CategoryDetailScreen
import com.chronir.feature.paywall.PaywallScreen
import com.chronir.feature.settings.AccountScreen
import com.chronir.feature.settings.AccountViewModel
import com.chronir.feature.settings.CompletionHistoryScreen
import com.chronir.feature.settings.LegalDocumentScreen
import com.chronir.feature.settings.SettingsScreen
import com.chronir.feature.settings.SoundPickerScreen
import com.chronir.feature.settings.SubscriptionScreen
import com.chronir.feature.settings.WallpaperPickerScreen
import com.chronir.model.ThemePreference
import com.chronir.services.BillingService
import com.chronir.services.OverdueAlarmChecker
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
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
        selectedIcon = Icons.Filled.Notifications,
        unselectedIcon = Icons.Outlined.Notifications
    )

    data object Settings : Screen(
        route = "settings",
        label = "Settings",
        selectedIcon = Icons.Filled.Settings,
        unselectedIcon = Icons.Outlined.Settings
    )
}

private val screens = listOf(Screen.AlarmList, Screen.Settings)

// TODO: Replace with actual web client ID from Firebase Console → Authentication → Sign-in method → Google
private const val GOOGLE_WEB_CLIENT_ID = ""

private const val ROUTE_ALARM_CREATION = "alarm_creation"
private const val ROUTE_ALARM_DETAIL = "alarm_detail/{alarmId}"
private const val ROUTE_CATEGORY_DETAIL = "category_detail/{category}"
private const val ROUTE_COMPLETION_HISTORY = "completion_history"
private const val ROUTE_SOUND_PICKER = "sound_picker"
private const val ROUTE_WALLPAPER_PICKER = "wallpaper_picker"
private const val ROUTE_ACCOUNT = "account"
private const val ROUTE_SUBSCRIPTION = "subscription"
private const val ROUTE_PAYWALL = "paywall"
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
        enableEdgeToEdge()
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

            ChronirTheme(
                darkTheme = darkTheme ?: androidx.compose.foundation.isSystemInDarkTheme(),
                dynamicColor = settings.themePreference == ThemePreference.DYNAMIC,
                textScale = settings.textSizePreference.scaleFactor
            ) {
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?) {
        val data = intent?.data ?: return
        if (data.scheme == "chronir" && data.host == "alarm") {
            val alarmId = data.pathSegments?.firstOrNull()
            if (!alarmId.isNullOrBlank()) {
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

    LaunchedEffect(deepLinkAlarmId) {
        if (deepLinkAlarmId != null) {
            navController.navigate("alarm_detail/$deepLinkAlarmId") {
                launchSingleTop = true
            }
            onDeepLinkConsumed()
        }
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentDestination = navBackStackEntry?.destination
            val currentRoute = currentDestination?.route

            val hideBottomBar = currentRoute == ROUTE_ALARM_CREATION ||
                currentRoute == ROUTE_ALARM_DETAIL ||
                currentRoute == ROUTE_CATEGORY_DETAIL ||
                currentRoute == ROUTE_COMPLETION_HISTORY ||
                currentRoute == ROUTE_SOUND_PICKER ||
                currentRoute == ROUTE_WALLPAPER_PICKER ||
                currentRoute == ROUTE_ACCOUNT ||
                currentRoute == ROUTE_SUBSCRIPTION ||
                currentRoute == ROUTE_PAYWALL ||
                currentRoute == ROUTE_LEGAL
            if (!hideBottomBar) {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface,
                    contentColor = MaterialTheme.colorScheme.onSurface
                ) {
                    screens.forEach { screen ->
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
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.AlarmList.route) {
                AlarmListScreen(
                    onNavigateToCreation = {
                        navController.navigate(ROUTE_ALARM_CREATION)
                    },
                    onNavigateToDetail = { alarmId ->
                        navController.navigate("alarm_detail/$alarmId")
                    }
                )
            }
            composable(Screen.Settings.route) {
                SettingsScreen(
                    onNavigateToHistory = {
                        navController.navigate(ROUTE_COMPLETION_HISTORY)
                    },
                    onNavigateToSoundPicker = {
                        navController.navigate(ROUTE_SOUND_PICKER)
                    },
                    onNavigateToWallpaper = {
                        navController.navigate(ROUTE_WALLPAPER_PICKER)
                    },
                    onNavigateToAccount = {
                        navController.navigate(ROUTE_ACCOUNT)
                    },
                    onNavigateToSubscription = {
                        navController.navigate(ROUTE_SUBSCRIPTION)
                    },
                    onNavigateToLegal = { title, url ->
                        val encodedUrl = java.net.URLEncoder.encode(url, "UTF-8")
                        navController.navigate("legal/$title/$encodedUrl")
                    }
                )
            }
            composable(ROUTE_ALARM_CREATION) {
                AlarmCreationScreen(
                    onDismiss = { navController.popBackStack() }
                )
            }
            composable(
                route = ROUTE_ALARM_DETAIL,
                arguments = listOf(navArgument("alarmId") { type = NavType.StringType })
            ) {
                AlarmDetailScreen(
                    onDismiss = { navController.popBackStack() }
                )
            }
            composable(
                route = ROUTE_CATEGORY_DETAIL,
                arguments = listOf(navArgument("category") { type = NavType.StringType })
            ) { backStackEntry ->
                CategoryDetailScreen(
                    category = backStackEntry.arguments?.getString("category") ?: "",
                    onBack = { navController.popBackStack() },
                    onNavigateToDetail = { alarmId ->
                        navController.navigate("alarm_detail/$alarmId")
                    }
                )
            }
            composable(ROUTE_COMPLETION_HISTORY) {
                CompletionHistoryScreen(
                    onBack = { navController.popBackStack() }
                )
            }
            composable(ROUTE_SOUND_PICKER) {
                SoundPickerScreen(
                    onBack = { navController.popBackStack() }
                )
            }
            composable(ROUTE_WALLPAPER_PICKER) {
                WallpaperPickerScreen(
                    onBack = { navController.popBackStack() }
                )
            }
            composable(ROUTE_ACCOUNT) {
                val context = LocalContext.current
                val scope = rememberCoroutineScope()
                val accountViewModel: AccountViewModel =
                    androidx.hilt.navigation.compose.hiltViewModel()
                AccountScreen(
                    onBack = { navController.popBackStack() },
                    onSignInClicked = {
                        if (GOOGLE_WEB_CLIENT_ID.isEmpty()) {
                            android.widget.Toast.makeText(
                                context,
                                "Google Sign-In not configured yet",
                                android.widget.Toast.LENGTH_SHORT
                            ).show()
                            return@AccountScreen
                        }
                        scope.launch {
                            try {
                                val googleIdOption = GetGoogleIdOption.Builder()
                                    .setFilterByAuthorizedAccounts(false)
                                    .setServerClientId(GOOGLE_WEB_CLIENT_ID)
                                    .build()
                                val request = GetCredentialRequest.Builder()
                                    .addCredentialOption(googleIdOption)
                                    .build()
                                val credentialManager = CredentialManager.create(context)
                                val result = credentialManager.getCredential(
                                    context = context as android.app.Activity,
                                    request = request
                                )
                                val googleIdToken = GoogleIdTokenCredential
                                    .createFrom(result.credential.data)
                                    .idToken
                                accountViewModel.signInWithGoogleIdToken(googleIdToken)
                            } catch (e: GetCredentialException) {
                                Log.e("GoogleSignIn", "Sign-in failed", e)
                            }
                        }
                    }
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
