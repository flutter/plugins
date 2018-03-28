package io.flutter.plugins.firebase.firebaseremoteconfig;

import android.content.Context;
import android.content.SharedPreferences;
import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigFetchThrottledException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigInfo;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/** FirebaseRemoteConfigPlugin */
public class FirebaseRemoteConfigPlugin implements MethodCallHandler {

  public static final String TAG = "FirebaseRemoteConfigPlugin";
  public static final String PREFS_NAME = "io.flutter.plugins.firebase.firebaseremoteconfig.FirebaseRemoteConfigPlugin";
  public static final String DEFAULT_PREF_KEY = "default_keys";


  private static SharedPreferences sharedPreferences;
  private final MethodChannel channel;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_remote_config");
    channel.setMethodCallHandler(new FirebaseRemoteConfigPlugin(channel));
    sharedPreferences =
        registrar.context().getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
  }

  private FirebaseRemoteConfigPlugin(MethodChannel channel) {
    this.channel = channel;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "RemoteConfig#instance":
        {
          FirebaseRemoteConfigInfo firebaseRemoteConfigInfo =
              FirebaseRemoteConfig.getInstance().getInfo();

          Map<String, Object> properties = new HashMap<>();
          properties.put("LAST_FETCH_TIME", firebaseRemoteConfigInfo.getFetchTimeMillis());
          properties.put(
              "LAST_FETCH_STATUS",
              mapLastFetchStatus(firebaseRemoteConfigInfo.getLastFetchStatus()));
          properties.put(
              "IN_DEBUG_MODE",
              firebaseRemoteConfigInfo.getConfigSettings().isDeveloperModeEnabled());
          properties.put("PARAMETERS", getConfigParameters());
          result.success(properties);
          break;
        }
      case "RemoteConfig#setConfigSettings":
        {
          boolean debugMode = call.argument("debugMode");
          final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
          FirebaseRemoteConfigSettings settings =
              new FirebaseRemoteConfigSettings.Builder().setDeveloperModeEnabled(debugMode).build();
          firebaseRemoteConfig.setConfigSettings(settings);
          result.success(null);
          break;
        }
      case "RemoteConfig#fetch":
        {
          long expiration =
              call.argument("expiration") instanceof Integer
                  ? Long.valueOf((Integer) call.argument("expiration"))
                  : (Long) call.argument("expiration");
          final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
          firebaseRemoteConfig
              .fetch(expiration)
              .addOnCompleteListener(
                  new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                      FirebaseRemoteConfigInfo firebaseRemoteConfigInfo =
                          firebaseRemoteConfig.getInfo();
                      Map<String, Object> properties = new HashMap<>();
                      properties.put(
                          "LAST_FETCH_TIME", firebaseRemoteConfigInfo.getFetchTimeMillis());
                      properties.put(
                          "LAST_FETCH_STATUS",
                          mapLastFetchStatus(firebaseRemoteConfigInfo.getLastFetchStatus()));
                      if (!task.isSuccessful()) {
                        final Exception exception = task.getException();

                        if (exception instanceof FirebaseRemoteConfigFetchThrottledException) {
                          properties.put("FETCH_THROTTLED_END",
                                  ((FirebaseRemoteConfigFetchThrottledException) exception)
                                          .getThrottleEndTimeMillis());
                          result.error("FETCH_FAILED_THROTTLED", null, properties);
                        } else {
                          result.error("FETCH_FAILED", null, properties);
                        }
                      } else {
                        result.success(properties);
                      }
                    }
                  });
          break;
        }
      case "RemoteConfig#activate":
        {
          FirebaseRemoteConfig.getInstance().activateFetched();
          result.success(getConfigParameters());
          break;
        }
      case "RemoteConfig#setDefaults":
        {
          Map<String, Object> defaults = call.argument("defaults");
          FirebaseRemoteConfig.getInstance().setDefaults(defaults);
          SharedPreferences.Editor editor = sharedPreferences.edit();
          editor.putStringSet(DEFAULT_PREF_KEY, defaults.keySet()).apply();
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

  private Map<String, Object> getConfigParameters() {
    FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
    Map<String, Object> parameterMap = new HashMap<>();
    Set<String> keys = firebaseRemoteConfig.getKeysByPrefix("");
    for (String key : keys) {
      FirebaseRemoteConfigValue remoteConfigValue = firebaseRemoteConfig.getValue(key);
      parameterMap.put(key, createRemoteConfigValueMap(remoteConfigValue));
    }
    // Add default parameters if missing since `getKeysByPrefix` does not return default keys.
    Set<String> defaultKeys =
            sharedPreferences.getStringSet(DEFAULT_PREF_KEY, new HashSet<String>());
    for (String defaultKey : defaultKeys) {
      if (!parameterMap.containsKey(defaultKey)) {
        FirebaseRemoteConfigValue remoteConfigValue =
                firebaseRemoteConfig.getValue(defaultKey);
        parameterMap.put(defaultKey, createRemoteConfigValueMap(remoteConfigValue));
      }
    }
    return parameterMap;
  }

  private Map<String, Object> createRemoteConfigValueMap(
      FirebaseRemoteConfigValue remoteConfigValue) {
    Map<String, Object> valueMap = new HashMap<>();
    valueMap.put("value", remoteConfigValue.asByteArray());
    valueMap.put("source", mapValueSource(remoteConfigValue.getSource()));
    return valueMap;
  }

  private int mapLastFetchStatus(int status) {
    switch (status) {
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_SUCCESS:
        return 0;
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_FAILURE:
        return 1;
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_THROTTLED:
        return 2;
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_NO_FETCH_YET:
        return 3;
      default:
        return 1;
    }
  }

  private int mapValueSource(int source) {
    switch (source) {
      case FirebaseRemoteConfig.VALUE_SOURCE_STATIC:
        return 0;
      case FirebaseRemoteConfig.VALUE_SOURCE_DEFAULT:
        return 1;
      case FirebaseRemoteConfig.VALUE_SOURCE_REMOTE:
        return 2;
      default:
        return 0;
    }
  }
}
