package com.chronir

import android.os.Bundle
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import kotlinx.coroutines.launch
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.chronir.data.repository.SettingsRepository
import com.chronir.designsystem.theme.ChronirTheme
import androidx.navigation.NavType
import androidx.navigation.navArgument
import com.chronir.feature.alarmcreation.AlarmCreationScreen
import com.chronir.feature.alarmdetail.AlarmDetailScreen
import com.chronir.feature.alarmlist.AlarmListScreen
import com.chronir.feature.settings.SettingsScreen
import com.chronir.model.ThemePreference
import dagger.hilt.android.AndroidEntryPoint
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

private const val ROUTE_ALARM_CREATION = "alarm_creation"
private const val ROUTE_ALARM_DETAIL = "alarm_detail/{alarmId}"

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
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
                    ChronirNavigation()
                }
            }
        }
    }
}

@Composable
private fun ChronirNavigation() {
    val navController = rememberNavController()

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentDestination = navBackStackEntry?.destination
            val currentRoute = currentDestination?.route

            val hideBottomBar = currentRoute == ROUTE_ALARM_CREATION ||
                currentRoute == ROUTE_ALARM_DETAIL
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
                SettingsScreen()
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
        }
    }
}
