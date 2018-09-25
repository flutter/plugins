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
import com.google.firebase.FirebaseApp;
import com.google.firebase.firestore.Blob;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.FirebaseFirestoreSettings;
import com.google.firebase.firestore.GeoPoint;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Transaction;
import com.google.firebase.firestore.WriteBatch;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.common.StandardMethodCodec;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class CloudFirestorePlugin implements MethodCallHandler {

  public static final String TAG = "CloudFirestorePlugin";
  private final MethodChannel channel;

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextListenerHandle = 0;
  private int nextBatchHandle = 0;
  private final SparseArray<EventObserver> observers = new SparseArray<>();
  private final SparseArray<DocumentObserver> documentObservers = new SparseArray<>();
  private final SparseArray<ListenerRegistration> listenerRegistrations = new SparseArray<>();
  private final SparseArray<WriteBatch> batches = new SparseArray<>();
  private final SparseArray<Transaction> transactions = new SparseArray<>();
  private final SparseArray<TaskCompletionSource> completionTasks = new SparseArray<>();

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(
            registrar.messenger(),
            "plugins.flutter.io/cloud_firestore",
            new StandardMethodCodec(FirestoreMessageCodec.INSTANCE));
    channel.setMethodCallHandler(new CloudFirestorePlugin(channel));
  }

  private CloudFirestorePlugin(MethodChannel channel) {
    this.channel = channel;
  }

  private FirebaseFirestore getFirestore(Map<String, Object> arguments) {
    String appName = (String) arguments.get("app");
    return FirebaseFirestore.getInstance(FirebaseApp.getInstance(appName));
  }

  private CollectionReference getCollectionReference(Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    return getFirestore(arguments).collection(path);
  }

  private DocumentReference getDocumentReference(Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    return getFirestore(arguments).document(path);
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
      } else if ("array-contains".equals(operator)) {
        query = query.whereArrayContains(fieldName, value);
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
      if (e != null) {
        // TODO: send error
        System.out.println(e);
        return;
      }
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
        return;
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
          getFirestore(arguments)
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
                              // result.error(errorCode, errorMessage, errorDetails);
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
      case "WriteBatch#create":
        {
          int handle = nextBatchHandle++;
          final Map<String, Object> arguments = call.arguments();
          WriteBatch batch = getFirestore(arguments).batch();
          batches.put(handle, batch);
          result.success(handle);
          break;
        }
      case "WriteBatch#setData":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = (Integer) arguments.get("handle");
          DocumentReference reference = getDocumentReference(arguments);
          @SuppressWarnings("unchecked")
          Map<String, Object> options = (Map<String, Object>) arguments.get("options");
          WriteBatch batch = batches.get(handle);
          if (options != null && (Boolean) options.get("merge")) {
            batch.set(reference, arguments.get("data"), SetOptions.merge());
          } else {
            batch.set(reference, arguments.get("data"));
          }
          result.success(null);
          break;
        }
      case "WriteBatch#updateData":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = (Integer) arguments.get("handle");
          DocumentReference reference = getDocumentReference(arguments);
          @SuppressWarnings("unchecked")
          Map<String, Object> data = (Map<String, Object>) arguments.get("data");
          WriteBatch batch = batches.get(handle);
          batch.update(reference, data);
          result.success(null);
          break;
        }
      case "WriteBatch#delete":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = (Integer) arguments.get("handle");
          DocumentReference reference = getDocumentReference(arguments);
          WriteBatch batch = batches.get(handle);
          batch.delete(reference);
          result.success(null);
          break;
        }
      case "WriteBatch#commit":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = (Integer) arguments.get("handle");
          WriteBatch batch = batches.get(handle);
          Task<Void> task = batch.commit();
          batches.delete(handle);
          addDefaultListeners("commit", task, result);
          break;
        }
      case "Query#addSnapshotListener":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = nextListenerHandle++;
          EventObserver observer = new EventObserver(handle);
          observers.put(handle, observer);
          listenerRegistrations.put(handle, getQuery(arguments).addSnapshotListener(observer));
          result.success(handle);
          break;
        }
      case "Query#addDocumentListener":
        {
          Map<String, Object> arguments = call.arguments();
          int handle = nextListenerHandle++;
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
          @SuppressWarnings("unchecked")
          Map<String, Object> data = (Map<String, Object>) arguments.get("data");
          Task<Void> task;
          if (options != null && (Boolean) options.get("merge")) {
            task = documentReference.set(data, SetOptions.merge());
          } else {
            task = documentReference.set(data);
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
      case "Firestore#enablePersistence":
        {
          Map<String, Object> arguments = call.arguments();
          Boolean enable = (Boolean) arguments.get("enable");
          FirebaseFirestoreSettings.Builder builder = new FirebaseFirestoreSettings.Builder();
          builder.setPersistenceEnabled(enable);
          FirebaseFirestoreSettings settings = builder.build();
          getFirestore(arguments).setFirestoreSettings(settings);
          result.success(null);
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

final class FirestoreMessageCodec extends StandardMessageCodec {
  public static final FirestoreMessageCodec INSTANCE = new FirestoreMessageCodec();
  private static final Charset UTF8 = Charset.forName("UTF8");
  private static final byte DATE_TIME = (byte) 128;
  private static final byte GEO_POINT = (byte) 129;
  private static final byte DOCUMENT_REFERENCE = (byte) 130;
  private static final byte BLOB = (byte) 131;
  private static final byte ARRAY_UNION = (byte) 132;
  private static final byte ARRAY_REMOVE = (byte) 133;
  private static final byte DELETE = (byte) 134;
  private static final byte SERVER_TIMESTAMP = (byte) 135;

  @Override
  protected void writeValue(ByteArrayOutputStream stream, Object value) {
    if (value instanceof Date) {
      stream.write(DATE_TIME);
      writeLong(stream, ((Date) value).getTime());
    } else if (value instanceof GeoPoint) {
      stream.write(GEO_POINT);
      writeAlignment(stream, 8);
      writeDouble(stream, ((GeoPoint) value).getLatitude());
      writeDouble(stream, ((GeoPoint) value).getLongitude());
    } else if (value instanceof DocumentReference) {
      stream.write(DOCUMENT_REFERENCE);
      writeBytes(
          stream, ((DocumentReference) value).getFirestore().getApp().getName().getBytes(UTF8));
      writeBytes(stream, ((DocumentReference) value).getPath().getBytes(UTF8));
    } else if (value instanceof Blob) {
      stream.write(BLOB);
      writeBytes(stream, ((Blob) value).toBytes());
    } else {
      super.writeValue(stream, value);
    }
  }

  @Override
  protected Object readValueOfType(byte type, ByteBuffer buffer) {
    switch (type) {
      case DATE_TIME:
        return new Date(buffer.getLong());
      case GEO_POINT:
        readAlignment(buffer, 8);
        return new GeoPoint(buffer.getDouble(), buffer.getDouble());
      case DOCUMENT_REFERENCE:
        final byte[] appNameBytes = readBytes(buffer);
        String appName = new String(appNameBytes, UTF8);
        final FirebaseFirestore firestore =
            FirebaseFirestore.getInstance(FirebaseApp.getInstance(appName));
        final byte[] pathBytes = readBytes(buffer);
        final String path = new String(pathBytes, UTF8);
        return firestore.document(path);
      case BLOB:
        final byte[] bytes = readBytes(buffer);
        return Blob.fromBytes(bytes);
      case ARRAY_UNION:
        return FieldValue.arrayUnion(toArray(readValue(buffer)));
      case ARRAY_REMOVE:
        return FieldValue.arrayRemove(toArray(readValue(buffer)));
      case DELETE:
        return FieldValue.delete();
      case SERVER_TIMESTAMP:
        return FieldValue.serverTimestamp();
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  private Object[] toArray(Object source) {
    if (source instanceof List) {
      return ((List) source).toArray();
    }

    if (source == null) {
      return new Object[0];
    }

    String sourceType = source.getClass().getCanonicalName();
    String message = "java.util.List was expected, unable to convert '%s' to an object array";
    throw new IllegalArgumentException(String.format(message, sourceType));
  }
}
