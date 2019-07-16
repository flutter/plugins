package com.example.firebase_in_app_messaging;

import com.google.firebase.inappmessaging.FirebaseInAppMessaging;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebaseInAppMessagingPlugin */
public class FirebaseInAppMessagingPlugin implements MethodCallHandler {
  private final FirebaseInAppMessaging instance;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_inappmessaging");
    channel.setMethodCallHandler(new FirebaseInAppMessagingPlugin());
  }

  private FirebaseInAppMessagingPlugin() {
    instance = FirebaseInAppMessaging.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "triggerEvent":
        {
          String eventName = call.argument("eventName");
          instance.triggerEvent(eventName);
          result.success(null);
          break;
        }
      case "setMessagesSuppressed":
        {
          boolean suppress = call.argument("suppress");
          instance.setMessagesSuppressed(suppress);
          result.success(null);
          break;
        }
      case "setAutomaticDataCollectionEnabled":
        {
          boolean setAutomaticDataCollectionEnabled = call.argument("setAutomaticDataCollectionEnabled");
          instance.setAutomaticDataCollectionEnabled(setAutomaticDataCollectionEnabled);
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
