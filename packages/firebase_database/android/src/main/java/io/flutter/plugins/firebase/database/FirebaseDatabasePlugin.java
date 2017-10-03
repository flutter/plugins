// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import android.util.SparseArray;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseException;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.HashMap;
import java.util.Map;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements MethodCallHandler {

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

  private DatabaseReference getReference(Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    DatabaseReference reference = FirebaseDatabase.getInstance().getReference();
    if (path != null) reference = reference.child(path);
    return reference;
  }

  private Query getQuery(Map<String, Object> arguments) {
    Query query = getReference(arguments);
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
        } else if (startAt instanceof String) {
          query = query.startAt((String) startAt, startAtKey);
        } else {
          query = query.startAt(((Number) startAt).doubleValue(), startAtKey);
        }
      } else {
        if (startAt instanceof Boolean) {
          query = query.startAt((Boolean) startAt);
        } else if (startAt instanceof String) {
          query = query.startAt((String) startAt);
        } else {
          query = query.startAt(((Number) startAt).doubleValue());
        }
      }
    }
    if (parameters.containsKey("endAt")) {
      Object endAt = parameters.get("endAt");
      if (parameters.containsKey("endAtKey")) {
        String endAtKey = (String) parameters.get("endAtKey");
        if (endAt instanceof Boolean) {
          query = query.endAt((Boolean) endAt, endAtKey);
        } else if (endAt instanceof String) {
          query = query.endAt((String) endAt, endAtKey);
        } else {
          query = query.endAt(((Number) endAt).doubleValue(), endAtKey);
        }
      } else {
        if (endAt instanceof Boolean) {
          query = query.endAt((Boolean) endAt);
        } else if (endAt instanceof String) {
          query = query.endAt((String) endAt);
        } else {
          query = query.endAt(((Number) endAt).doubleValue());
        }
      }
    }
    if (parameters.containsKey("equalTo")) {
      Object equalTo = parameters.get("equalTo");
      if (equalTo instanceof Boolean) {
        query = query.equalTo((Boolean) equalTo);
      } else if (equalTo instanceof String) {
        query = query.equalTo((String) equalTo);
      } else {
        query = query.equalTo(((Number) equalTo).doubleValue());
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
    public void onCancelled(DatabaseError error) {}

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
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "FirebaseDatabase#goOnline":
        {
          FirebaseDatabase.getInstance().goOnline();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#goOffline":
        {
          FirebaseDatabase.getInstance().goOffline();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#purgeOutstandingWrites":
        {
          FirebaseDatabase.getInstance().purgeOutstandingWrites();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#setPersistenceEnabled":
        {
          Boolean isEnabled = (Boolean) call.arguments;
          try {
            FirebaseDatabase.getInstance().setPersistenceEnabled(isEnabled);
            result.success(true);
          } catch (DatabaseException e) {
            // Database is already in use, e.g. after hot reload/restart.
            result.success(false);
          }
          break;
        }

      case "FirebaseDatabase#setPersistenceCacheSizeBytes":
        {
          long cacheSize = (Integer) call.arguments;
          try {
            FirebaseDatabase.getInstance().setPersistenceCacheSizeBytes(cacheSize);
            result.success(true);
          } catch (DatabaseException e) {
            // Database is already in use, e.g. after hot reload/restart.
            result.success(false);
          }
          break;
        }

      case "DatabaseReference#set":
        {
          Map<String, Object> arguments = call.arguments();
          Object value = arguments.get("value");
          Object priority = arguments.get("priority");
          DatabaseReference reference = getReference(arguments);
          if (priority != null) {
            reference.setValue(value, priority, new DefaultCompletionListener(result));
          } else {
            reference.setValue(value, new DefaultCompletionListener(result));
          }
          break;
        }

      case "DatabaseReference#update":
        {
          Map<String, Object> arguments = call.arguments();
          Map value = (Map) arguments.get("value");
          DatabaseReference reference = getReference(arguments);
          reference.updateChildren(value, new DefaultCompletionListener(result));
          break;
        }

      case "DatabaseReference#setPriority":
        {
          Map<String, Object> arguments = call.arguments();
          Object priority = arguments.get("priority");
          DatabaseReference reference = getReference(arguments);
          reference.setPriority(priority, new DefaultCompletionListener(result));
          break;
        }

      case "Query#keepSynced":
        {
          Map<String, Object> arguments = call.arguments();
          boolean value = (Boolean) arguments.get("value");
          getQuery(arguments).keepSynced(value);
          result.success(null);
          break;
        }

      case "Query#observe":
        {
          Map<String, Object> arguments = call.arguments();
          String eventType = (String) arguments.get("eventType");
          int handle = nextHandle++;
          EventObserver observer = new EventObserver(eventType, handle);
          observers.put(handle, observer);
          if (eventType.equals(EVENT_TYPE_VALUE)) {
            getQuery(arguments).addValueEventListener(observer);
          } else {
            getQuery(arguments).addChildEventListener(observer);
          }
          result.success(handle);
          break;
        }

      case "Query#removeObserver":
        {
          Map<String, Object> arguments = call.arguments();
          Query query = getQuery(arguments);
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
}
