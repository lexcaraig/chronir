package com.cyclealarm.data.repository

import com.cyclealarm.data.remote.AuthDataSource
import com.cyclealarm.data.remote.FirestoreDataSource
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserRepository @Inject constructor(
    private val authDataSource: AuthDataSource,
    private val firestoreDataSource: FirestoreDataSource
) {

    fun isAuthenticated(): Boolean = authDataSource.isAuthenticated()

    fun getCurrentUserId(): String? = authDataSource.getCurrentUserId()

    fun signOut() = authDataSource.signOut()
}
