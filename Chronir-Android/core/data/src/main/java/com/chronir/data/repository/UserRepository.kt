package com.chronir.data.repository

import com.chronir.data.remote.AuthDataSource
import com.chronir.data.remote.FirestoreDataSource
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

data class UserProfile(
    val uid: String,
    val displayName: String?,
    val email: String?,
    val photoUrl: String?
)

@Singleton
class UserRepository
    @Inject
    constructor(
        private val authDataSource: AuthDataSource,
        private val firestoreDataSource: FirestoreDataSource
    ) {

        val currentUserProfile: Flow<UserProfile?> = authDataSource.currentUser.map { user ->
            user?.let {
                UserProfile(
                    uid = it.uid,
                    displayName = it.displayName,
                    email = it.email,
                    photoUrl = it.photoUrl?.toString()
                )
            }
        }

        fun isAuthenticated(): Boolean = authDataSource.isAuthenticated()

        fun getCurrentUserId(): String? = authDataSource.getCurrentUserId()

        suspend fun signInWithGoogleIdToken(idToken: String) {
            authDataSource.signInWithGoogleIdToken(idToken)
        }

        suspend fun deleteAccount() = authDataSource.deleteAccount()

        fun signOut() = authDataSource.signOut()
    }
