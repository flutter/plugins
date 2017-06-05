package io.flutter.plugins.firebase.database;

import android.util.SparseArray;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
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
  private final SparseArray<EventObserver> observers = new SparseArray<EventObserver>();

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_database");
    channel.setMethodCallHandler(new FirebaseDatabasePlugin(channel));
  }

  private FirebaseDatabasePlugin(MethodChannel channel) {
    this.channel = channel;
  }

  private static DatabaseReference getReference(Map<String, ?> arguments) {
    @SuppressWarnings("unchecked")
    String path = (String) arguments.get("path");
    DatabaseReference reference = FirebaseDatabase.getInstance().getReference();
    if (path != null) reference = reference.child(path);
    return reference;
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
        Map<String, Object> arguments = new HashMap<String, Object>();
        Map<String, Object> snapshotMap = new HashMap<String, Object>();
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

  @SuppressWarnings("unchecked")
  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    switch (call.method) {
      case "FirebaseDatabase#goOnline":
        FirebaseDatabase.getInstance().goOnline();
        break;

      case "FirebaseDatabase#goOffline":
        FirebaseDatabase.getInstance().goOffline();
        break;

      case "FirebaseDatabase#purgeOutstandingWrites":
        FirebaseDatabase.getInstance().purgeOutstandingWrites();
        break;

      case "FirebaseDatabase#setPersistenceEnabled":
        {
          boolean isEnabled = (boolean) arguments.get("enabled");
          FirebaseDatabase.getInstance().setPersistenceEnabled(isEnabled);
          break;
        }

      case "FirebaseDatabase#setPersistenceCacheSizeBytes":
        {
          long cacheSize = (long) arguments.get("cacheSize");
          FirebaseDatabase.getInstance().setPersistenceCacheSizeBytes(cacheSize);
          break;
        }

      case "DatabaseReference#set":
        {
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

      case "DatabaseReference#setPriority":
        {
          Object priority = arguments.get("priority");
          DatabaseReference reference = getReference(arguments);
          reference.setPriority(priority, new DefaultCompletionListener(result));
          break;
        }

      case "Query#observe":
        {
          String eventType = (String) arguments.get("eventType");
          int handle = nextHandle++;
          EventObserver observer = new EventObserver(eventType, handle);
          observers.put(handle, observer);
          if (eventType.equals(EVENT_TYPE_VALUE)) {
            getReference(arguments).addValueEventListener(observer);
          } else {
            getReference(arguments).addChildEventListener(observer);
          }
          result.success(handle);
          break;
        }

      case "Query#removeObserver":
        {
          DatabaseReference reference = getReference(arguments);
          int handle = (Integer) arguments.get("handle");
          EventObserver observer = observers.get(handle);
          if (observer != null) {
            if (observer.requestedEventType.equals(EVENT_TYPE_VALUE)) {
              reference.removeEventListener((ValueEventListener) observer);
            } else {
              reference.removeEventListener((ChildEventListener) observer);
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
