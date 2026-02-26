package com.chronir.data.remote

import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FirestoreDataSource
    @Inject
    constructor() {

        private val firestore: FirebaseFirestore by lazy {
            FirebaseFirestore.getInstance()
        }

        private fun userAlarmsCollection(uid: String) =
            firestore.collection("users").document(uid).collection("alarms")

        suspend fun pushAlarm(uid: String, alarmId: String, data: Map<String, Any?>) {
            userAlarmsCollection(uid).document(alarmId).set(data).await()
        }

        suspend fun fetchAllRemoteAlarms(uid: String): List<Map<String, Any>> {
            val snapshot = userAlarmsCollection(uid).get().await()
            return snapshot.documents.mapNotNull { doc ->
                doc.data?.plus("id" to doc.id)
            }
        }

        suspend fun deleteRemoteAlarm(uid: String, alarmId: String) {
            userAlarmsCollection(uid).document(alarmId).delete().await()
        }

        suspend fun uploadAllAlarms(uid: String, alarms: List<Pair<String, Map<String, Any?>>>) {
            // Firestore batch limit is 500 writes
            alarms.chunked(500).forEach { chunk ->
                val batch = firestore.batch()
                chunk.forEach { (alarmId, data) ->
                    val ref = userAlarmsCollection(uid).document(alarmId)
                    batch.set(ref, data)
                }
                batch.commit().await()
            }
        }

        suspend fun deleteAllCloudData(uid: String) {
            val docs = userAlarmsCollection(uid).get().await()
            docs.documents.chunked(500).forEach { chunk ->
                val batch = firestore.batch()
                chunk.forEach { doc -> batch.delete(doc.reference) }
                batch.commit().await()
            }
            // Delete the user document itself
            firestore.collection("users").document(uid).delete().await()
        }
    }
