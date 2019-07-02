package com.example.firebase_inappmessaging;

import com.google.firebase.inappmessaging.FirebaseInAppMessaging;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebaseInappmessagingPlugin */
public class FirebaseInappmessagingPlugin implements MethodCallHandler {
  private final FirebaseInAppMessaging instance;

  public static void registerWith(Registrar registrar) {

    final MethodChannel channel = new MethodChannel(registrar.messenger(),
          "plugins.flutter.io/firebase_inappmessaging");
    channel.setMethodCallHandler(new FirebaseInappmessagingPlugin());
  }

  private FirebaseInappmessagingPlugin() {
    instance = FirebaseInAppMessaging.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "triggerEvent": {
        String eventName = call.argument("eventName");
        instance.triggerEvent(eventName);
        result.success(null);
        break;
      }
      case "setMessagesSuppressed": {
        boolean suppress = call.argument("suppress");
        instance.setMessagesSuppressed(suppress);
        result.success(null);
        break;
      }
      case "dataCollectionEnabled": {
        boolean dataCollectionEnabled = call.argument("dataCollectionEnabled");
        instance.setAutomaticDataCollectionEnabled(dataCollectionEnabled);
        result.success(null);
        break;
      }
      default: {
        result.notImplemented();
        break;
      }
    }
  }
}
