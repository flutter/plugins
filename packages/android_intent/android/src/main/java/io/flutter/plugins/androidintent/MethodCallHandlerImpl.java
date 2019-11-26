package io.flutter.plugins.androidintent;

import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/** Forwards incoming {@link MethodCall}s to {@link IntentSender#send}. */
public final class MethodCallHandlerImpl implements MethodCallHandler {
  private static final String TAG = "MethodCallHandlerImpl";
  private final IntentSender sender;
  @Nullable private MethodChannel methodChannel;

  /**
   * Uses the given {@code sender} for all incoming calls.
   *
   * <p>This assumes that the sender's context and activity state are managed elsewhere and
   * correctly initialized before being sent here.
   */
  MethodCallHandlerImpl(IntentSender sender) {
    this.sender = sender;
  }

  /**
   * Registers this instance as a method call handler on the given {@code messenger}.
   *
   * <p>Stops any previously started and unstopped calls.
   *
   * <p>This should be cleaned with {@link #stopListening} once the messenger is disposed of.
   */
  void startListening(BinaryMessenger messenger) {
    if (methodChannel != null) {
      Log.wtf(TAG, "Setting a method call handler before the last was disposed.");
      stopListening();
    }

    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/android_intent");
    methodChannel.setMethodCallHandler(this);
  }

  /**
   * Clears this instance from listening to method calls.
   *
   * <p>Does nothing is {@link #startListening} hasn't been called, or if we're already stopped.
   */
  void stopListening() {
    if (methodChannel == null) {
      Log.d(TAG, "Tried to stop listening when no methodChannel had been initialized.");
      return;
    }

    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
  }

  /**
   * Parses the incoming call and forwards it to the cached {@link IntentSender}.
   *
   * <p>Always calls {@code result#success}.
   */
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("launch")) {
      String action = convertAction((String) call.argument("action"));
      Integer flags = call.argument("flags");
      String category = call.argument("category");
      Uri data = call.argument("data") != null ? Uri.parse((String) call.argument("data")) : null;
      Bundle arguments = convertMapToBundle((Map<String, ?>) call.argument("arguments"));
      String packageName = call.argument("package");
      ComponentName componentName =
          (!TextUtils.isEmpty(packageName)
                  && !TextUtils.isEmpty((String) call.argument("componentName")))
              ? new ComponentName(packageName, (String) call.argument("componentName"))
              : null;

      sender.send(action, flags, category, data, arguments, packageName, componentName);

      result.success(null);
    } else if (call.method.equals("getIntentExtras")) {
      if (sender.getActivity() != null) {
        Intent intent = sender.getActivity().getIntent();
        result.success(convertBundleToMap(intent.getExtras()));
      }
    } else if (call.method.equals("setIntentExtra")) {
      if (sender.getActivity() != null) {
        Intent intent = sender.getActivity().getIntent();
        Map extras = new HashMap(1);
        extras.put((String) call.argument("name"), call.argument("value"));
        intent.putExtras(convertMapToBundle(extras));
      }
    } else if (call.method.equals("getIntentData")) {
      if (sender.getActivity() != null) {
        Intent intent = sender.getActivity().getIntent();
        result.success(intent.getData());
      }
    }
  }

  private static String convertAction(String action) {
    switch (action) {
      case "action_view":
        return Intent.ACTION_VIEW;
      case "action_voice":
        return Intent.ACTION_VOICE_COMMAND;
      case "settings":
        return Settings.ACTION_SETTINGS;
      case "action_location_source_settings":
        return Settings.ACTION_LOCATION_SOURCE_SETTINGS;
      case "action_application_details_settings":
        return Settings.ACTION_APPLICATION_DETAILS_SETTINGS;
      default:
        return action;
    }
  }

  private static Bundle convertMapToBundle(Map<String, ?> arguments) {
    Bundle bundle = new Bundle();
    if (arguments == null) {
      return bundle;
    }
    for (String key : arguments.keySet()) {
      Object value = arguments.get(key);
      if (value instanceof Integer) {
        bundle.putInt(key, (Integer) value);
      } else if (value instanceof String) {
        bundle.putString(key, (String) value);
      } else if (value instanceof Boolean) {
        bundle.putBoolean(key, (Boolean) value);
      } else if (value instanceof Double) {
        bundle.putDouble(key, (Double) value);
      } else if (value instanceof Long) {
        bundle.putLong(key, (Long) value);
      } else if (value instanceof byte[]) {
        bundle.putByteArray(key, (byte[]) value);
      } else if (value instanceof int[]) {
        bundle.putIntArray(key, (int[]) value);
      } else if (value instanceof long[]) {
        bundle.putLongArray(key, (long[]) value);
      } else if (value instanceof double[]) {
        bundle.putDoubleArray(key, (double[]) value);
      } else if (isTypedArrayList(value, Integer.class)) {
        bundle.putIntegerArrayList(key, (ArrayList<Integer>) value);
      } else if (isTypedArrayList(value, String.class)) {
        bundle.putStringArrayList(key, (ArrayList<String>) value);
      } else if (isStringKeyedMap(value)) {
        bundle.putBundle(key, convertMapToBundle((Map<String, ?>) value));
      } else {
        throw new UnsupportedOperationException("Unsupported type " + value);
      }
    }
    return bundle;
  }

  private Map<String, Object> convertBundleToMap(Bundle bundle) {
    Map<String, Object> arguments = new HashMap<String, Object>();
    if (bundle != null) {
      for (String key : bundle.keySet()) {
        Object value = bundle.get(key);

        if (value instanceof Integer) {
          arguments.put(key, (Integer) value);
        } else if (value instanceof String) {
          arguments.put(key, (String) value);
        } else if (value instanceof Boolean) {
          arguments.put(key, (Boolean) value);
        } else if (value instanceof Double) {
          arguments.put(key, (Double) value);
        } else if (value instanceof Long) {
          arguments.put(key, (Long) value);
        } else if (value instanceof byte[]) {
          arguments.put(key, (byte[]) value);
        } else if (value instanceof int[]) {
          arguments.put(key, (int[]) value);
        } else if (value instanceof long[]) {
          arguments.put(key, (long[]) value);
        } else if (value instanceof double[]) {
          arguments.put(key, (double[]) value);
        } else if (isTypedArrayList(value, Integer.class)) {
          arguments.put(key, (ArrayList<Integer>) value);
        } else if (isTypedArrayList(value, String.class)) {
          arguments.put(key, (ArrayList<String>) value);
        } else if (value instanceof Bundle) {
          arguments.put(key, convertBundleToMap((Bundle) value));
        } else {
          throw new UnsupportedOperationException("Unsupported type " + value);
        }
      }
    }
    return arguments;
  }

  private static boolean isTypedArrayList(Object value, Class<?> type) {
    if (!(value instanceof ArrayList)) {
      return false;
    }
    ArrayList list = (ArrayList) value;
    for (Object o : list) {
      if (!(o == null || type.isInstance(o))) {
        return false;
      }
    }
    return true;
  }

  private static boolean isStringKeyedMap(Object value) {
    if (!(value instanceof Map)) {
      return false;
    }
    Map map = (Map) value;
    for (Object key : map.keySet()) {
      if (!(key == null || key instanceof String)) {
        return false;
      }
    }
    return true;
  }
}
