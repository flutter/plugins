package com.clanhq.firestore

import com.google.firebase.firestore.DocumentChange
import com.google.firebase.firestore.DocumentSnapshot
import java.util.*

/**
 * Created by philipp on 10/20/17.
 */
fun documentSnapshotToMap(it: DocumentSnapshot): HashMap<String, Any> {
    val m = HashMap<String, Any>()

    val cleandata: HashMap<String, Any> = HashMap()
    it.data.forEach {
        if (it.value is Date) {
            cleandata.put(it.key, (it.value as Date).time)
        } else {
            cleandata.put(it.key, it.value)
        }
    }
    m.put("data", cleandata)
    m.put("id", it.id)

    return m
}

fun documentChangeTypeToString(type: DocumentChange.Type): String = when (type) {
    DocumentChange.Type.ADDED -> "DocumentChangeType.added"
    DocumentChange.Type.MODIFIED -> "DocumentChangeType.modified"
    DocumentChange.Type.REMOVED -> "DocumentChangeType.removed"
}
