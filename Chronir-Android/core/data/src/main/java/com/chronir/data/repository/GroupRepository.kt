package com.chronir.data.repository

import com.chronir.data.remote.FirestoreDataSource
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class GroupRepository
    @Inject
    constructor(
        private val firestoreDataSource: FirestoreDataSource
    ) {
        // TODO: Implement group CRUD operations via Firestore
    }
