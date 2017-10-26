package com.clanhq.firestore

import com.google.firebase.firestore.DocumentChange
import com.google.firebase.firestore.DocumentSnapshot
import java.util.HashMap

/**
 * Created by philipp on 10/20/17.
 */
fun documentSnapshotToMap(it: DocumentSnapshot): Map<String, Any> {
    val m = HashMap<String, Any>()
    m.put("data", it.data)
    m.put("id", it.id)

    return m
}

fun documentChangeTypeToString(type: DocumentChange.Type): String = when (type) {
    DocumentChange.Type.ADDED -> "DocumentChangeType.added"
    DocumentChange.Type.MODIFIED -> "DocumentChangeType.modified"
    DocumentChange.Type.REMOVED -> "DocumentChangeType.removed"
}
