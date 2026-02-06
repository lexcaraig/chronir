package com.cyclealarm.data.repository

import com.cyclealarm.data.remote.FirestoreDataSource
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class GroupRepository @Inject constructor(
    private val firestoreDataSource: FirestoreDataSource
) {
    // TODO: Implement group CRUD operations via Firestore
}
