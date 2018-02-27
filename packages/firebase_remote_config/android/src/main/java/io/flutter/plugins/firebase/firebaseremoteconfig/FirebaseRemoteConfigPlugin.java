package io.flutter.plugins.firebase.firebaseremoteconfig;

import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FirebaseRemoteConfigPlugin
 */
public class FirebaseRemoteConfigPlugin implements MethodCallHandler {

  public static final String TAG = "FirebbaseRCPlugin";

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "firebase_remote_config");
    channel.setMethodCallHandler(new FirebaseRemoteConfigPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "RemoteConfig#fetch":
        {
          boolean debugMode = call.argument("debugMode");
          long expiration = call.argument("expiration") instanceof Integer ?
                  Long.valueOf((Integer) call.argument("expiration")) :
                  (Long) call.argument("expiration");
          final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
          FirebaseRemoteConfigSettings settings = new FirebaseRemoteConfigSettings.Builder()
                  .setDeveloperModeEnabled(debugMode).build();
          firebaseRemoteConfig.setConfigSettings(settings);
          firebaseRemoteConfig.fetch(expiration).addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
              firebaseRemoteConfig.activateFetched();
              Map<String, Object> keyMap = new HashMap<>();
              Set<String> keys = firebaseRemoteConfig.getKeysByPrefix("");
              for (String key : keys) {
                keyMap.put(key, firebaseRemoteConfig.getValue(key).asByteArray());
              }
              result.success(keyMap);
            }
          });
          break;
        }
      case "RemoteConfig#setDefaults":
        {
          Map<String, Object> defaults = call.argument("defaults");
          FirebaseRemoteConfig.getInstance().setDefaults(defaults);
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
