package com.chronir.data.remote

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthDataSource
    @Inject
    constructor() {

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

        fun getCurrentUser(): FirebaseUser? = auth.currentUser

        fun isAuthenticated(): Boolean = auth.currentUser != null

        suspend fun signInWithGoogleIdToken(idToken: String): FirebaseUser? {
            val credential = GoogleAuthProvider.getCredential(idToken, null)
            val result = auth.signInWithCredential(credential).await()
            return result.user
        }

        suspend fun deleteAccount() {
            auth.currentUser?.delete()?.await()
        }

        fun signOut() {
            auth.signOut()
        }
    }
