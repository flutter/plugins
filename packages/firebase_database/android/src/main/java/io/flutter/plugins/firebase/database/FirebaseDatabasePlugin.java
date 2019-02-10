// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import android.util.Log;
import android.util.SparseArray;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseException;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Query;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.ValueEventListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements MethodCallHandler {

  private static final String TAG = "FirebaseDatabasePlugin";

  private final MethodChannel channel;
  private static final String EVENT_TYPE_CHILD_ADDED = "_EventType.childAdded";
  private static final String EVENT_TYPE_CHILD_REMOVED = "_EventType.childRemoved";
  private static final String EVENT_TYPE_CHILD_CHANGED = "_EventType.childChanged";
  private static final String EVENT_TYPE_CHILD_MOVED = "_EventType.childMoved";
  private static final String EVENT_TYPE_VALUE = "_EventType.value";

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;
  private final SparseArray<EventObserver> observers = new SparseArray<>();

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_database");
    channel.setMethodCallHandler(new FirebaseDatabasePlugin(channel));
  }

  private FirebaseDatabasePlugin(MethodChannel channel) {
    this.channel = channel;
  }

  private DatabaseReference getReference(FirebaseDatabase database, Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    DatabaseReference reference = database.getReference();
    if (path != null) reference = reference.child(path);
    return reference;
  }

  private Query getQuery(FirebaseDatabase database, Map<String, Object> arguments) {
    Query query = getReference(database, arguments);
    @SuppressWarnings("unchecked")
    Map<String, Object> parameters = (Map<String, Object>) arguments.get("parameters");
    if (parameters == null) return query;
    Object orderBy = parameters.get("orderBy");
    if ("child".equals(orderBy)) {
      query = query.orderByChild((String) parameters.get("orderByChildKey"));
    } else if ("key".equals(orderBy)) {
      query = query.orderByKey();
    } else if ("value".equals(orderBy)) {
      query = query.orderByValue();
    } else if ("priority".equals(orderBy)) {
      query = query.orderByPriority();
    }
    if (parameters.containsKey("startAt")) {
      Object startAt = parameters.get("startAt");
      if (parameters.containsKey("startAtKey")) {
        String startAtKey = (String) parameters.get("startAtKey");
        if (startAt instanceof Boolean) {
          query = query.startAt((Boolean) startAt, startAtKey);
        } else if (startAt instanceof Number) {
          query = query.startAt(((Number) startAt).doubleValue(), startAtKey);
        } else {
          query = query.startAt((String) startAt, startAtKey);
        }
      } else {
        if (startAt instanceof Boolean) {
          query = query.startAt((Boolean) startAt);
        } else if (startAt instanceof Number) {
          query = query.startAt(((Number) startAt).doubleValue());
        } else {
          query = query.startAt((String) startAt);
        }
      }
    }
    if (parameters.containsKey("endAt")) {
      Object endAt = parameters.get("endAt");
      if (parameters.containsKey("endAtKey")) {
        String endAtKey = (String) parameters.get("endAtKey");
        if (endAt instanceof Boolean) {
          query = query.endAt((Boolean) endAt, endAtKey);
        } else if (endAt instanceof Number) {
          query = query.endAt(((Number) endAt).doubleValue(), endAtKey);
        } else {
          query = query.endAt((String) endAt, endAtKey);
        }
      } else {
        if (endAt instanceof Boolean) {
          query = query.endAt((Boolean) endAt);
        } else if (endAt instanceof Number) {
          query = query.endAt(((Number) endAt).doubleValue());
        } else {
          query = query.endAt((String) endAt);
        }
      }
    }
    if (parameters.containsKey("equalTo")) {
      Object equalTo = parameters.get("equalTo");
      if (parameters.containsKey("equalToKey")) {
        String equalToKey = (String) parameters.get("equalToKey");
        if (equalTo instanceof Boolean) {
          query = query.equalTo((Boolean) equalTo, equalToKey);
        } else if (equalTo instanceof Number) {
          query = query.equalTo(((Number) equalTo).doubleValue(), equalToKey);
        } else {
          query = query.equalTo((String) equalTo, equalToKey);
        }
      } else {
        if (equalTo instanceof Boolean) {
          query = query.equalTo((Boolean) equalTo);
        } else if (equalTo instanceof Number) {
          query = query.equalTo(((Number) equalTo).doubleValue());
        } else {
          query = query.equalTo((String) equalTo);
        }
      }
    }
    if (parameters.containsKey("limitToFirst")) {
      query = query.limitToFirst((int) parameters.get("limitToFirst"));
    }
    if (parameters.containsKey("limitToLast")) {
      query = query.limitToLast((int) parameters.get("limitToLast"));
    }
    return query;
  }

  private class DefaultCompletionListener implements DatabaseReference.CompletionListener {
    private final Result result;

    DefaultCompletionListener(Result result) {
      this.result = result;
    }

    @Override
    public void onComplete(DatabaseError error, DatabaseReference ref) {
      if (error != null) {
        result.error(String.valueOf(error.getCode()), error.getMessage(), error.getDetails());
      } else {
        result.success(null);
      }
    }
  }

  private class EventObserver implements ChildEventListener, ValueEventListener {
    private String requestedEventType;
    private int handle;

    EventObserver(String requestedEventType, int handle) {
      this.requestedEventType = requestedEventType;
      this.handle = handle;
    }

    private void sendEvent(String eventType, DataSnapshot snapshot, String previousChildName) {
      if (eventType.equals(requestedEventType)) {
        Map<String, Object> arguments = new HashMap<>();
        Map<String, Object> snapshotMap = new HashMap<>();
        snapshotMap.put("key", snapshot.getKey());
        snapshotMap.put("value", snapshot.getValue());
        arguments.put("handle", handle);
        arguments.put("snapshot", snapshotMap);
        arguments.put("previousSiblingKey", previousChildName);
        channel.invokeMethod("Event", arguments);
      }
    }

    @Override
    public void onCancelled(DatabaseError error) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("handle", handle);
      arguments.put("error", asMap(error));
      channel.invokeMethod("Error", arguments);
    }

    @Override
    public void onChildAdded(DataSnapshot snapshot, String previousChildName) {
      sendEvent(EVENT_TYPE_CHILD_ADDED, snapshot, previousChildName);
    }

    @Override
    public void onChildRemoved(DataSnapshot snapshot) {
      sendEvent(EVENT_TYPE_CHILD_REMOVED, snapshot, null);
    }

    @Override
    public void onChildChanged(DataSnapshot snapshot, String previousChildName) {
      sendEvent(EVENT_TYPE_CHILD_CHANGED, snapshot, previousChildName);
    }

    @Override
    public void onChildMoved(DataSnapshot snapshot, String previousChildName) {
      sendEvent(EVENT_TYPE_CHILD_MOVED, snapshot, previousChildName);
    }

    @Override
    public void onDataChange(DataSnapshot snapshot) {
      sendEvent(EVENT_TYPE_VALUE, snapshot, null);
    }
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    final Map<String, Object> arguments = call.arguments();
    FirebaseDatabase database;
    String appName = (String) arguments.get("app");
    String databaseURL = (String) arguments.get("databaseURL");
    if (appName != null && databaseURL != null) {
      database = FirebaseDatabase.getInstance(FirebaseApp.getInstance(appName), databaseURL);
    } else if (appName != null) {
      database = FirebaseDatabase.getInstance(FirebaseApp.getInstance(appName));
    } else if (databaseURL != null) {
      database = FirebaseDatabase.getInstance(databaseURL);
    } else {
      database = FirebaseDatabase.getInstance();
    }
    switch (call.method) {
      case "FirebaseDatabase#goOnline":
        {
          database.goOnline();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#goOffline":
        {
          database.goOffline();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#purgeOutstandingWrites":
        {
          database.purgeOutstandingWrites();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#setPersistenceEnabled":
        {
          Boolean isEnabled = (Boolean) arguments.get("enabled");
          try {
            database.setPersistenceEnabled(isEnabled);
            result.success(true);
          } catch (DatabaseException e) {
            // Database is already in use, e.g. after hot reload/restart.
            result.success(false);
          }
          break;
        }

      case "FirebaseDatabase#setPersistenceCacheSizeBytes":
        {
          long cacheSize = (Integer) arguments.get("cacheSize");
          try {
            database.setPersistenceCacheSizeBytes(cacheSize);
            result.success(true);
          } catch (DatabaseException e) {
            // Database is already in use, e.g. after hot reload/restart.
            result.success(false);
          }
          break;
        }

      case "DatabaseReference#set":
        {
          Object value = arguments.get("value");
          Object priority = arguments.get("priority");
          DatabaseReference reference = getReference(database, arguments);
          if (priority != null) {
            reference.setValue(value, priority, new DefaultCompletionListener(result));
          } else {
            reference.setValue(value, new DefaultCompletionListener(result));
          }
          break;
        }

      case "DatabaseReference#update":
        {
          @SuppressWarnings("unchecked")
          Map<String, Object> value = (Map<String, Object>) arguments.get("value");
          DatabaseReference reference = getReference(database, arguments);
          reference.updateChildren(value, new DefaultCompletionListener(result));
          break;
        }

      case "DatabaseReference#setPriority":
        {
          Object priority = arguments.get("priority");
          DatabaseReference reference = getReference(database, arguments);
          reference.setPriority(priority, new DefaultCompletionListener(result));
          break;
        }

      case "DatabaseReference#runTransaction":
        {
          final DatabaseReference reference = getReference(database, arguments);

          // Initiate native transaction.
          reference.runTransaction(
              new Transaction.Handler() {
                @Override
                public Transaction.Result doTransaction(MutableData mutableData) {
                  // Tasks are used to allow native execution of doTransaction to wait while Snapshot is
                  // processed by logic on the Dart side.
                  final TaskCompletionSource<Map<String, Object>> updateMutableDataTCS =
                      new TaskCompletionSource<>();
                  final Task<Map<String, Object>> updateMutableDataTCSTask =
                      updateMutableDataTCS.getTask();

                  Map<String, Object> doTransactionMap = new HashMap<>();
                  doTransactionMap.put("transactionKey", arguments.get("transactionKey"));

                  final Map<String, Object> snapshotMap = new HashMap<>();
                  snapshotMap.put("key", mutableData.getKey());
                  snapshotMap.put("value", mutableData.getValue());
                  doTransactionMap.put("snapshot", snapshotMap);

                  // Return snapshot to Dart side for update.
                  channel.invokeMethod(
                      "DoTransaction",
                      doTransactionMap,
                      new MethodChannel.Result() {
                        @Override
                        @SuppressWarnings("unchecked")
                        public void success(Object result) {
                          updateMutableDataTCS.setResult((Map<String, Object>) result);
                        }

                        @Override
                        public void error(
                            String errorCode, String errorMessage, Object errorDetails) {
                          String exceptionMessage =
                              "Error code: "
                                  + errorCode
                                  + "\nError message: "
                                  + errorMessage
                                  + "\nError details: "
                                  + errorDetails;
                          updateMutableDataTCS.setException(new Exception(exceptionMessage));
                        }

                        @Override
                        public void notImplemented() {
                          updateMutableDataTCS.setException(
                              new Exception("DoTransaction not implemented on Dart side."));
                        }
                      });

                  try {
                    // Wait for updated snapshot from the Dart side.
                    Map<String, Object> updatedSnapshotMap =
                        Tasks.await(
                            updateMutableDataTCSTask,
                            (int) arguments.get("transactionTimeout"),
                            TimeUnit.MILLISECONDS);
                    // Set value of MutableData to value returned from the Dart side.
                    mutableData.setValue(updatedSnapshotMap.get("value"));
                  } catch (ExecutionException | InterruptedException | TimeoutException e) {
                    Log.e(TAG, "Unable to commit Snapshot update. Transaction failed.", e);
                    if (e instanceof TimeoutException) {
                      Log.e(TAG, "Transaction at " + reference.toString() + " timed out.");
                    }
                    return Transaction.abort();
                  }
                  return Transaction.success(mutableData);
                }

                @Override
                public void onComplete(
                    DatabaseError databaseError, boolean committed, DataSnapshot dataSnapshot) {
                  Map<String, Object> completionMap = new HashMap<>();
                  completionMap.put("transactionKey", arguments.get("transactionKey"));
                  if (databaseError != null) {
                    completionMap.put("error", asMap(databaseError));
                  }
                  completionMap.put("committed", committed);
                  if (dataSnapshot != null) {
                    Map<String, Object> snapshotMap = new HashMap<>();
                    snapshotMap.put("key", dataSnapshot.getKey());
                    snapshotMap.put("value", dataSnapshot.getValue());
                    completionMap.put("snapshot", snapshotMap);
                  }

                  // Invoke transaction completion on the Dart side.
                  result.success(completionMap);
                }
              });
          break;
        }

      case "OnDisconnect#set":
        {
          Object value = arguments.get("value");
          Object priority = arguments.get("priority");
          DatabaseReference reference = getReference(database, arguments);
          if (priority != null) {
            if (priority instanceof String) {
              reference
                  .onDisconnect()
                  .setValue(value, (String) priority, new DefaultCompletionListener(result));
            } else if (priority instanceof Double) {
              reference
                  .onDisconnect()
                  .setValue(value, (double) priority, new DefaultCompletionListener(result));
            } else if (priority instanceof Map) {
              reference
                  .onDisconnect()
                  .setValue(value, (Map) priority, new DefaultCompletionListener(result));
            }
          } else {
            reference.onDisconnect().setValue(value, new DefaultCompletionListener(result));
          }
          break;
        }

      case "OnDisconnect#update":
        {
          @SuppressWarnings("unchecked")
          Map<String, Object> value = (Map<String, Object>) arguments.get("value");
          DatabaseReference reference = getReference(database, arguments);
          reference.onDisconnect().updateChildren(value, new DefaultCompletionListener(result));
          break;
        }

      case "OnDisconnect#cancel":
        {
          DatabaseReference reference = getReference(database, arguments);
          reference.onDisconnect().cancel(new DefaultCompletionListener(result));
          break;
        }

      case "Query#keepSynced":
        {
          boolean value = (Boolean) arguments.get("value");
          getQuery(database, arguments).keepSynced(value);
          result.success(null);
          break;
        }

      case "Query#observe":
        {
          String eventType = (String) arguments.get("eventType");
          int handle = nextHandle++;
          EventObserver observer = new EventObserver(eventType, handle);
          observers.put(handle, observer);
          if (eventType.equals(EVENT_TYPE_VALUE)) {
            getQuery(database, arguments).addValueEventListener(observer);
          } else {
            getQuery(database, arguments).addChildEventListener(observer);
          }
          result.success(handle);
          break;
        }

      case "Query#removeObserver":
        {
          Query query = getQuery(database, arguments);
          int handle = (Integer) arguments.get("handle");
          EventObserver observer = observers.get(handle);
          if (observer != null) {
            if (observer.requestedEventType.equals(EVENT_TYPE_VALUE)) {
              query.removeEventListener((ValueEventListener) observer);
            } else {
              query.removeEventListener((ChildEventListener) observer);
            }
            observers.delete(handle);
            result.success(null);
            break;
          } else {
            result.error("unknown_handle", "removeObserver called on an unknown handle", null);
            break;
          }
        }

      default:
        {
          result.notImplemented();
          break;
        }
    }
  }

  private static Map<String, Object> asMap(DatabaseError error) {
    Map<String, Object> map = new HashMap<>();
    map.put("code", error.getCode());
    map.put("message", error.getMessage());
    map.put("details", error.getDetails());
    return map;
  }
}
