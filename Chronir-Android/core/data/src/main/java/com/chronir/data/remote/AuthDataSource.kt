package com.chronir.data.remote

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthDataSource @Inject constructor() {

    private val auth: FirebaseAuth by lazy {
        FirebaseAuth.getInstance()
    }

    private val _currentUser = MutableStateFlow<FirebaseUser?>(null)
    val currentUser: Flow<FirebaseUser?> = _currentUser

    init {
        auth.addAuthStateListener { firebaseAuth ->
            _currentUser.value = firebaseAuth.currentUser
        }
    }

    fun getCurrentUserId(): String? = auth.currentUser?.uid

    fun isAuthenticated(): Boolean = auth.currentUser != null

    fun signOut() {
        auth.signOut()
    }
}
