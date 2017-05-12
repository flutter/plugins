package io.flutter.plugins.firebase.database;

import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements MethodCallHandler {

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_database");
    channel.setMethodCallHandler(new FirebaseDatabasePlugin(channel));
  }

  private FirebaseDatabasePlugin(final MethodChannel channel) {
    FirebaseDatabase.getInstance()
        .getReference()
        .limitToLast(10)
        .addChildEventListener(
            new ChildEventListener() {
              @Override
              public void onCancelled(DatabaseError error) {}

              @Override
              public void onChildAdded(DataSnapshot snapshot, String previousChildName) {
                List arguments = Arrays.asList(snapshot.getKey(), snapshot.getValue());
                channel.invokeMethod("DatabaseReference#childAdded", arguments);
              }

              @Override
              public void onChildChanged(DataSnapshot snapshot, String previousChildName) {}

              @Override
              public void onChildMoved(DataSnapshot snapshot, String previousChildName) {}

              @Override
              public void onChildRemoved(DataSnapshot snapshot) {}
            });
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("DatabaseReference#set")) {
      List arguments = (List) call.arguments;
      Map data = (Map) arguments.get(0);
      DatabaseReference ref = FirebaseDatabase.getInstance().getReference().push();
      ref.updateChildren(
          data,
          new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError error, DatabaseReference ref) {
              if (error != null) {
                result.error(
                    String.valueOf(error.getCode()), error.getMessage(), error.getDetails());
              } else {
                result.success(null);
              }
            }
          });
    } else {
      result.notImplemented();
    }
  }
}
