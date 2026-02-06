package com.chronir.data.remote

import com.google.firebase.firestore.FirebaseFirestore
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FirestoreDataSource @Inject constructor() {

    private val firestore: FirebaseFirestore by lazy {
        FirebaseFirestore.getInstance()
    }

    fun alarmsCollection() = firestore.collection("alarms")

    fun groupsCollection() = firestore.collection("groups")

    fun usersCollection() = firestore.collection("users")

    fun completionRecordsCollection() = firestore.collection("completionRecords")
}
