package com.chronir.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronir.data.repository.UserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AccountUiState(
    val isSignedIn: Boolean = false,
    val displayName: String? = null,
    val email: String? = null,
    val photoUrl: String? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class AccountViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AccountUiState())
    val uiState: StateFlow<AccountUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            userRepository.currentUserProfile.collect { profile ->
                _uiState.update {
                    it.copy(
                        isSignedIn = profile != null,
                        displayName = profile?.displayName,
                        email = profile?.email,
                        photoUrl = profile?.photoUrl
                    )
                }
            }
        }
    }

    fun signInWithGoogleIdToken(idToken: String) {
        _uiState.update { it.copy(isLoading = true, errorMessage = null) }
        viewModelScope.launch {
            try {
                userRepository.signInWithGoogleIdToken(idToken)
                _uiState.update { it.copy(isLoading = false) }
            } catch (_: Exception) {
                _uiState.update {
                    it.copy(isLoading = false, errorMessage = "Sign-in failed. Please try again.")
                }
            }
        }
    }

    fun signOut() {
        userRepository.signOut()
    }

    fun deleteAccount() {
        viewModelScope.launch {
            try {
                userRepository.deleteAccount()
            } catch (_: Exception) {
                _uiState.update {
                    it.copy(errorMessage = "Failed to delete account. Please sign in again and retry.")
                }
            }
        }
    }
}
