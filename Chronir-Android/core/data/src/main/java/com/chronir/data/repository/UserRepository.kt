package com.chronir.data.repository

import com.chronir.data.remote.AuthDataSource
import com.chronir.data.remote.FirestoreDataSource
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
