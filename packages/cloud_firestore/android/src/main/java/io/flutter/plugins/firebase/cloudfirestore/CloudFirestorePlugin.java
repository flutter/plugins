// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.cloudfirestore;

import android.support.annotation.NonNull;
import android.util.SparseArray;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CloudFirestorePlugin implements MethodCallHandler {

  private final MethodChannel channel;

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;
  private final SparseArray<EventObserver> observers = new SparseArray<>();
  private final SparseArray<DocumentObserver> documentObservers = new SparseArray<>();
  private final SparseArray<ListenerRegistration> listenerRegistrations = new SparseArray<>();

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
    List<Object> orderBy = (List<Object>) parameters.get("orderBy");
    if (orderBy == null) return query;
    String orderByFieldName = (String) orderBy.get(0);
    Boolean descending = (Boolean) orderBy.get(1);
    Query.Direction direction = descending ? Query.Direction.DESCENDING : Query.Direction.ASCENDING;
    return query.orderBy(orderByFieldName, direction);
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
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("handle", handle);

      List<String> paths = new ArrayList<>();
      List<Map<String, Object>> documents = new ArrayList<>();
      for (DocumentSnapshot document : querySnapshot.getDocuments()) {
        paths.add(document.getReference().getPath());
        documents.add(document.getData());
      }
      arguments.put("paths", paths);
      arguments.put("documents", documents);

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
      arguments.put("documentChanges", documentChanges);

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
        }
      case "Query#removeListener":
        {
          Map<String, Object> arguments = call.arguments();
          // TODO(arthurthompson): find out why removeListener is sometimes called without handle.
          int handle = (Integer) arguments.get("handle");
          listenerRegistrations.get(handle).remove();
          listenerRegistrations.remove(handle);
          observers.remove(handle);
          result.success(null);
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
