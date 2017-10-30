package com.clanhq.firestore

import android.util.SparseArray
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.firebase.firestore.*
import com.google.firebase.firestore.EventListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

class FirestorePlugin internal constructor(private val channel: MethodChannel) : MethodCallHandler {
    private var nextHandle = 0
    private val queryObservers = SparseArray<QueryObserver>()
    private val documentObservers = SparseArray<DocumentObserver>()
    private val listenerRegistrations = SparseArray<ListenerRegistration>()


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "firestore")
            channel.setMethodCallHandler(FirestorePlugin(channel))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when (call.method) {
            "DocumentReference#setData" -> {
                val arguments = call.arguments<Map<String, Any?>>()
                val documentReference = getDocumentReference(arguments["path"] as String)
                val data = arguments["data"] as Map<*, *>

                val newValues = HashMap<String, Any?>()

                data.entries.forEach {
                    if (it.value == ".sv") {
                        newValues[it.key as String] = FieldValue.serverTimestamp()
                    } else {
                        newValues[it.key as String] = it.value
                    }
                }
                documentReference.set(newValues)

                result.success(null)
            }
            "Query#addSnapshotListener" -> {
                val arguments = call.arguments<Map<String, Any>>()
                val path = arguments["path"] as String

                val qp : QueryParameters = getQueryParameters(arguments["parameters"] as Map<*, *>?)

                val startAtTask: Task<DocumentSnapshot?> =
                        if (qp.startAtId != null) getDocumentReference("$path/$qp.startAtId").get()
                        else Tasks.forResult(null)

                val endAtTask: Task<DocumentSnapshot?> =
                        if (qp.endAtId != null) getDocumentReference("$path/$qp.endAtId").get()
                        else Tasks.forResult(null)

                Tasks.whenAll(startAtTask, endAtTask).addOnSuccessListener {
                    val startAtSnap: DocumentSnapshot? = startAtTask.result
                    val endAtSnap: DocumentSnapshot? = endAtTask.result

                    if (qp.startAtId != null && startAtSnap != null && !startAtSnap.exists()) {
                        resultErrorForDocumentId(result, qp.startAtId)
                    } else if (qp.endAtId != null && endAtSnap != null && !endAtSnap.exists()) {
                        resultErrorForDocumentId(result, qp.endAtId)
                    } else {
                        registerSnapshotListener(result, path, limit = qp.limit, orderBy = qp.orderBy, descending = qp.descending, startAt = startAtSnap, endAt = endAtSnap)
                    }

                }.addOnFailureListener {
                    if (qp.startAtId != null) resultErrorForDocumentId(result, qp.startAtId)
                    else if (qp.endAtId != null) resultErrorForDocumentId(result, qp.endAtId)
                }
            }
            "Query#getSnapshot" -> {
                val arguments = call.arguments<Map<String, Any>>()
                val path = arguments["path"] as String

                val qp : QueryParameters = getQueryParameters(arguments["parameters"] as Map<*, *>?)

                val startAtTask: Task<DocumentSnapshot?> =
                        if (qp.startAtId != null) getDocumentReference("$path/$qp.startAtId").get()
                        else Tasks.forResult(null)

                val startAfterTask: Task<DocumentSnapshot?> =
                        if (qp.startAfterId != null) getDocumentReference("$path/$qp.startAfterId").get()
                        else Tasks.forResult(null)


                Tasks.whenAll(startAtTask, startAfterTask).addOnCompleteListener {
                    val startAtSnap: DocumentSnapshot? = startAtTask.result
                    val startAfterSnap: DocumentSnapshot? = startAfterTask.result
                    val query = getQuery(path = path, limit = qp.limit, orderBy = qp.orderBy,
                            descending = qp.descending, startAt = startAtSnap,
                            startAfter = startAfterSnap, endAt = null)

                    query.get().addOnCompleteListener { task ->
                        val querySnapshot = task.result
                        val documents = querySnapshot.documents.map(::documentSnapshotToMap)
                        val resultArguments = HashMap<String, Any>()
                        resultArguments.put("documents", documents)
                        resultArguments.put("documentChanges", HashMap<String, Any>())
                        result.success(resultArguments)
                    }.addOnFailureListener {
                        if (qp.startAtId != null) resultErrorForDocumentId(result, qp.startAtId)
                        else if (qp.startAfterId != null) resultErrorForDocumentId(result, qp.startAfterId)
                    }
                }
            }

            "Query#addDocumentListener" -> {
                val arguments = call.arguments<Map<String, Any>>()
                val handle = nextHandle++
                val observer = DocumentObserver(handle)
                documentObservers.put(handle, observer)
                listenerRegistrations.put(
                        handle, getDocumentReference(arguments["path"] as String).addSnapshotListener(observer))
                result.success(handle)
            }
            "Query#removeQueryListener" -> {
                val arguments = call.arguments<Map<String, Any>>()
                val handle = arguments["handle"] as Int
                listenerRegistrations.get(handle).remove()
                listenerRegistrations.remove(handle)
                queryObservers.remove(handle)
                result.success(null)
            }
            "Query#removeDocumentListener" -> {
                val arguments = call.arguments<Map<String, Any>>()
                val handle = arguments["handle"] as Int
                listenerRegistrations.get(handle).remove()
                listenerRegistrations.remove(handle)
                documentObservers.remove(handle)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun registerSnapshotListener(
            result: Result,
            path: String,
            limit: Int?,
            orderBy: String?,
            descending: Boolean?,
            startAt: DocumentSnapshot? = null,
            startAfter: DocumentSnapshot? = null,
            endAt: DocumentSnapshot? = null
    ) {
        val handle = nextHandle++
        val observer = QueryObserver(handle)
        val query = getQuery(
                path = path,
                limit = limit,
                orderBy = orderBy,
                descending = descending,
                startAt = startAt,
                startAfter = startAfter,
                endAt = endAt)

        queryObservers.put(handle, observer)
        listenerRegistrations.put(handle, query.addSnapshotListener(observer))
        result.success(handle)
    }

    private inner class DocumentObserver internal constructor(private val handle: Int) : EventListener<DocumentSnapshot> {
        override fun onEvent(documentSnapshot: DocumentSnapshot, e: FirebaseFirestoreException?) {
            val arguments = HashMap<String, Any>()
            arguments.put("handle", handle)
            if (documentSnapshot.exists()) {
                arguments["data"] = documentSnapshot.data;
            }
            channel.invokeMethod("DocumentSnapshot", arguments)
        }
    }


    private inner class QueryObserver internal constructor(private val handle: Int) : EventListener<QuerySnapshot> {

        override fun onEvent(querySnapshot: QuerySnapshot, e: FirebaseFirestoreException?) {
            val arguments = HashMap<String, Any>()
            arguments.put("handle", handle)

            val documents = querySnapshot.documents.map(::documentSnapshotToMap)
            arguments.put("documents", documents)

            val documentChanges = ArrayList<Map<String, Any>>()
            for (documentChange in querySnapshot.documentChanges) {
                val change = HashMap<String, Any>()
                change.put("type", documentChange.type.ordinal)
                change.put("oldIndex", documentChange.oldIndex)
                change.put("newIndex", documentChange.newIndex)
                change.put("document", documentSnapshotToMap(documentChange.document))
                documentChanges.add(change)
            }
            arguments.put("documentChanges", documentChanges)

            channel.invokeMethod("QuerySnapshot", arguments)
        }
    }

    private fun getQuery(
            path: String,
            limit: Int?,
            orderBy: String?,
            descending: Boolean?,
            startAt: DocumentSnapshot?,
            startAfter: DocumentSnapshot?,
            endAt: DocumentSnapshot?): Query {

        var query: Query = getCollectionReference(path)

        if (limit != null) query = query.limit(limit.toLong())
        if (orderBy != null && descending != null) query = query.orderBy(orderBy, if (descending) Query.Direction.DESCENDING else Query.Direction.ASCENDING)
        if (orderBy != null && descending == null) query = query.orderBy(orderBy)

        if (startAt != null) query = query.startAt(startAt)
        if (startAfter != null) query = query.startAfter(startAt)
        if (endAt != null) query = query.endAt(endAt)

        return query
    }

    private fun resultErrorForDocumentId(result: Result, id: String) = result.error("ERR", "Error retrieving document with ID $id", null)
    private fun getCollectionReference(path: String): CollectionReference = FirebaseFirestore.getInstance().collection(path)

    private fun getDocumentReference(path: String): DocumentReference = FirebaseFirestore.getInstance().document(path)
}

fun getQueryParameters(parameters: Map<*, *>?): QueryParameters {
    val limit = parameters?.get("limit") as? Int
    val orderBy = parameters?.get("orderBy") as? String
    val descending = parameters?.get("descending") as? Boolean
    val startAtId = parameters?.get("startAtId") as? String
    val startAfterId = parameters?.get("startAtId") as? String
    val endAtId = parameters?.get("endAtId") as? String

    return QueryParameters(limit, orderBy, descending, startAtId, startAfterId, endAtId)
}

data class QueryParameters(val limit: Int?, val orderBy: String?, val descending: Boolean?, val startAtId: String?, val startAfterId: String?, val endAtId: String?) {

}
