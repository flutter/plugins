// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.cloudfirestore;

import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.SparseArray;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Transaction;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class CloudFirestorePlugin implements MethodCallHandler {

  public static final String TAG = "CloudFirestorePlugin";
  private final MethodChannel channel;

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;
  private final SparseArray<EventObserver> observers = new SparseArray<>();
  private final SparseArray<DocumentObserver> documentObservers = new SparseArray<>();
  private final SparseArray<ListenerRegistration> listenerRegistrations = new SparseArray<>();
  private final SparseArray<Transaction> transactions = new SparseArray<>();
  private final SparseArray<TaskCompletionSource> completionTasks = new SparseArray<>();

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/cloud_firestore");
    channel.setMethodCallHandler(new CloudFirestorePlugin(channel));
  }

  private CloudFirestorePlugin(MethodChannel channel) {
    this.channel = channel;
  }

  private CollectionReference getCollectionReference(Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    return FirebaseFirestore.getInstance().collection(path);
  }

  private DocumentReference getDocumentReference(Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    return FirebaseFirestore.getInstance().document(path);
  }

  private Map<String, Object> parseQuerySnapshot(QuerySnapshot querySnapshot) {
    if (querySnapshot == null) return new HashMap<>();
    Map<String, Object> data = new HashMap<>();
    List<String> paths = new ArrayList<>();
    List<Map<String, Object>> documents = new ArrayList<>();
    for (DocumentSnapshot document : querySnapshot.getDocuments()) {
      paths.add(document.getReference().getPath());
      documents.add(document.getData());
    }
    data.put("paths", paths);
    data.put("documents", documents);

    List<Map<String, Object>> documentChanges = new ArrayList<>();
    for (DocumentChange documentChange : querySnapshot.getDocumentChanges()) {
      Map<String, Object> change = new HashMap<>();
      String type = null;
      switch (documentChange.getType()) {
        case ADDED:
          type = "DocumentChangeType.added";
          break;
        case MODIFIED:
          type = "DocumentChangeType.modified";
          break;
        case REMOVED:
          type = "DocumentChangeType.removed";
          break;
      }
      change.put("type", type);
      change.put("oldIndex", documentChange.getOldIndex());
      change.put("newIndex", documentChange.getNewIndex());
      change.put("document", documentChange.getDocument().getData());
      change.put("path", documentChange.getDocument().getReference().getPath());
      documentChanges.add(change);
    }
    data.put("documentChanges", documentChanges);

    return data;
  }

  private Transaction getTransaction(Map<String, Object> arguments) {
    return transactions.get((Integer) arguments.get("transactionId"));
  }

  private Query getQuery(Map<String, Object> arguments) {
    Query query = getCollectionReference(arguments);
    @SuppressWarnings("unchecked")
    Map<String, Object> parameters = (Map<String, Object>) arguments.get("parameters");
    if (parameters == null) return query;
    @SuppressWarnings("unchecked")
    List<List<Object>> whereConditions = (List<List<Object>>) parameters.get("where");
    for (List<Object> condition : whereConditions) {
      String fieldName = (String) condition.get(0);
      String operator = (String) condition.get(1);
      Object value = condition.get(2);
      if ("==".equals(operator)) {
        query = query.whereEqualTo(fieldName, value);
      } else if ("<".equals(operator)) {
        query = query.whereLessThan(fieldName, value);
      } else if ("<=".equals(operator)) {
        query = query.whereLessThanOrEqualTo(fieldName, value);
      } else if (">".equals(operator)) {
        query = query.whereGreaterThan(fieldName, value);
      } else if (">=".equals(operator)) {
        query = query.whereGreaterThanOrEqualTo(fieldName, value);
      } else {
        // Invalid operator.
      }
    }
    @SuppressWarnings("unchecked")
    Number limit = (Number) parameters.get("limit");
    if (limit != null) query = query.limit(limit.longValue());
    @SuppressWarnings("unchecked")
    List<List<Object>> orderBy = (List<List<Object>>) parameters.get("orderBy");
    if (orderBy == null) return query;
    for (List<Object> order : orderBy) {
      String orderByFieldName = (String) order.get(0);
      Boolean descending = (Boolean) order.get(1);
      Query.Direction direction =
          descending ? Query.Direction.DESCENDING : Query.Direction.ASCENDING;
      query = query.orderBy(orderByFieldName, direction);
    }
    @SuppressWarnings("unchecked")
    List<Object> startAt = (List<Object>) parameters.get("startAt");
    if (startAt != null) query = query.startAt(startAt.toArray());
    @SuppressWarnings("unchecked")
    List<Object> startAfter = (List<Object>) parameters.get("startAfter");
    if (startAfter != null) query = query.startAfter(startAfter.toArray());
    @SuppressWarnings("unchecked")
    List<Object> endAt = (List<Object>) parameters.get("endAt");
    if (endAt != null) query = query.endAt(endAt.toArray());
    @SuppressWarnings("unchecked")
    List<Object> endBefore = (List<Object>) parameters.get("endBefore");
    if (endBefore != null) query = query.endBefore(endBefore.toArray());
    return query;
  }

  private class DocumentObserver implements EventListener<DocumentSnapshot> {
    private int handle;

    DocumentObserver(int handle) {
      this.handle = handle;
    }

    @Override
    public void onEvent(DocumentSnapshot documentSnapshot, FirebaseFirestoreException e) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("handle", handle);
      if (documentSnapshot.exists()) {
        arguments.put("data", documentSnapshot.getData());
        arguments.put("path", documentSnapshot.getReference().getPath());
      } else {
        arguments.put("data", null);
        arguments.put("path", documentSnapshot.getReference().getPath());
      }
      channel.invokeMethod("DocumentSnapshot", arguments);
    }
  }

  private class EventObserver implements EventListener<QuerySnapshot> {
    private int handle;

    EventObserver(int handle) {
      this.handle = handle;
    }

    @Override
    public void onEvent(QuerySnapshot querySnapshot, FirebaseFirestoreException e) {
      if (e != null) {
        // TODO: send error
        System.out.println(e);
      }

      Map<String, Object> arguments = parseQuerySnapshot(querySnapshot);
      arguments.put("handle", handle);

      channel.invokeMethod("QuerySnapshot", arguments);
    }
  }

  private void addDefaultListeners(final String description, Task<Void> task, final Result result) {
    task.addOnSuccessListener(
        new OnSuccessListener<Void>() {
          @Override
          public void onSuccess(Void ignored) {
            result.success(null);
          }
        });
    task.addOnFailureListener(
        new OnFailureListener() {
          @Override
          public void onFailure(@NonNull Exception e) {
            result.error("Error performing " + description, e.getMessage(), null);
          }
        });
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "Firestore#runTransaction":
        {
          final TaskCompletionSource<Map<String, Object>> transactionTCS =
              new TaskCompletionSource<>();
          final Task<Map<String, Object>> transactionTCSTask = transactionTCS.getTask();

          final Map<String, Object> arguments = call.arguments();
          FirebaseFirestore.getInstance()
              .runTransaction(
                  new Transaction.Function<Void>() {
                    @Nullable
                    @Override
                    public Void apply(@NonNull Transaction transaction)
                        throws FirebaseFirestoreException {
                      // Store transaction.
                      int transactionId = (Integer) arguments.get("transactionId");
                      transactions.append(transactionId, transaction);
                      completionTasks.append(transactionId, transactionTCS);

                      // Start operations on Dart side.
                      channel.invokeMethod(
                          "DoTransaction",
                          arguments,
                          new Result() {
                            @Override
                            public void success(Object doTransactionResult) {
                              transactionTCS.setResult((Map<String, Object>) doTransactionResult);
                            }

                            @Override
                            public void error(
                                String errorCode, String errorMessage, Object errorDetails) {
                              // result.error(errorCode, errorMessage, errroDetails);
                              transactionTCS.setException(new Exception("Do transaction failed."));
                            }

                            @Override
                            public void notImplemented() {
                              // result.error("DoTransaction not implemented", null, null);
                              transactionTCS.setException(
                                  new Exception("DoTransaction not implemented"));
                            }
                          });

                      // Wait till transaction is complete.
                      try {
                        String timeoutKey = "transactionTimeout";
                        long timeout = ((Number) arguments.get(timeoutKey)).longValue();
                        Map<String, Object> transactionResult =
                            Tasks.await(transactionTCSTask, timeout, TimeUnit.MILLISECONDS);

                        // Once transaction completes return the result to the Dart side.
                        result.success(transactionResult);
                      } catch (Exception e) {
                        result.error("Error performing transaction", e.getMessage(), null);
                      }
                      return null;
                    }
                  });
          break;
        }
      case "Transaction#get":
        {
          final Map<String, Object> arguments = call.arguments();
          final Transaction transaction = getTransaction(arguments);
          new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... voids) {
              try {
                DocumentSnapshot documentSnapshot =
                    transaction.get(getDocumentReference(arguments));
                Map<String, Object> snapshotMap = new HashMap<>();
                snapshotMap.put("path", documentSnapshot.getReference().getPath());
                if (documentSnapshot.exists()) {
                  snapshotMap.put("data", documentSnapshot.getData());
                } else {
                  snapshotMap.put("data", null);
                }
                result.success(snapshotMap);
              } catch (FirebaseFirestoreException e) {
                result.error("Error performing Transaction#get", e.getMessage(), null);
              }
              return null;
            }
          }.execute();
          break;
        }
      case "Transaction#update":
        {
          final Map<String, Object> arguments = call.arguments();
          final Transaction transaction = getTransaction(arguments);
          new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... voids) {
              Map<String, Object> data = (Map<String, Object>) arguments.get("data");
              try {
                transaction.update(getDocumentReference(arguments), data);
                result.success(null);
              } catch (IllegalStateException e) {
                result.error("Error performing Transaction#update", e.getMessage(), null);
              }
              return null;
            }
          }.execute();
          break;
        }
      case "Transaction#set":
        {
          final Map<String, Object> arguments = call.arguments();
          final Transaction transaction = getTransaction(arguments);
          new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... voids) {
              Map<String, Object> data = (Map<String, Object>) arguments.get("data");
              transaction.set(getDocumentReference(arguments), data);
              result.success(null);
              return null;
            }
          }.execute();
          break;
        }
      case "Transaction#delete":
        {
          final Map<String, Object> arguments = call.arguments();
          final Transaction transaction = getTransaction(arguments);
          new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... voids) {
              transaction.delete(getDocumentReference(arguments));
              result.success(null);
              return null;
            }
          }.execute();
          break;
        }
      case "Query#addSnapshotListener":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = nextHandle++;
          EventObserver observer = new EventObserver(handle);
          observers.put(handle, observer);
          listenerRegistrations.put(handle, getQuery(arguments).addSnapshotListener(observer));
          result.success(handle);
          break;
        }
      case "Query#addDocumentListener":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = nextHandle++;
          DocumentObserver observer = new DocumentObserver(handle);
          documentObservers.put(handle, observer);
          listenerRegistrations.put(
              handle, getDocumentReference(arguments).addSnapshotListener(observer));
          result.success(handle);
          break;
        }
      case "Query#removeListener":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = (Integer) arguments.get("handle");
          listenerRegistrations.get(handle).remove();
          listenerRegistrations.remove(handle);
          observers.remove(handle);
          result.success(null);
          break;
        }
      case "Query#getDocuments":
        {
          Map<String, Object> arguments = call.arguments();
          Query query = getQuery(arguments);
          Task<QuerySnapshot> task = query.get();
          task.addOnSuccessListener(
                  new OnSuccessListener<QuerySnapshot>() {
                    @Override
                    public void onSuccess(QuerySnapshot querySnapshot) {
                      result.success(parseQuerySnapshot(querySnapshot));
                    }
                  })
              .addOnFailureListener(
                  new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                      result.error("Error performing getDocuments", e.getMessage(), null);
                    }
                  });
          break;
        }
      case "DocumentReference#setData":
        {
          Map<String, Object> arguments = call.arguments();
          DocumentReference documentReference = getDocumentReference(arguments);
          @SuppressWarnings("unchecked")
          Map<String, Object> options = (Map<String, Object>) arguments.get("options");
          Task<Void> task;
          if (options != null && (Boolean) options.get("merge")) {
            task = documentReference.set(arguments.get("data"), SetOptions.merge());
          } else {
            task = documentReference.set(arguments.get("data"));
          }
          addDefaultListeners("setData", task, result);
          break;
        }
      case "DocumentReference#updateData":
        {
          Map<String, Object> arguments = call.arguments();
          DocumentReference documentReference = getDocumentReference(arguments);
          @SuppressWarnings("unchecked")
          Map<String, Object> data = (Map<String, Object>) arguments.get("data");
          Task<Void> task = documentReference.update(data);
          addDefaultListeners("updateData", task, result);
          break;
        }
      case "DocumentReference#get":
        {
          Map<String, Object> arguments = call.arguments();
          DocumentReference documentReference = getDocumentReference(arguments);
          Task<DocumentSnapshot> task = documentReference.get();
          task.addOnSuccessListener(
                  new OnSuccessListener<DocumentSnapshot>() {
                    @Override
                    public void onSuccess(DocumentSnapshot documentSnapshot) {
                      Map<String, Object> snapshotMap = new HashMap<>();
                      snapshotMap.put("path", documentSnapshot.getReference().getPath());
                      if (documentSnapshot.exists()) {
                        snapshotMap.put("data", documentSnapshot.getData());
                      } else {
                        snapshotMap.put("data", null);
                      }
                      result.success(snapshotMap);
                    }
                  })
              .addOnFailureListener(
                  new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                      result.error("Error performing get", e.getMessage(), null);
                    }
                  });
          break;
        }
      case "DocumentReference#delete":
        {
          Map<String, Object> arguments = call.arguments();
          DocumentReference documentReference = getDocumentReference(arguments);
          Task<Void> task = documentReference.delete();
          addDefaultListeners("delete", task, result);
          break;
        }
      default:
        {
          result.notImplemented();
          break;
        }
    }
  }
}
