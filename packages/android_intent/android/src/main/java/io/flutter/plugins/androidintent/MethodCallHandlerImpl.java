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
    String action = convertAction((String) call.argument("action"));
    Integer flags = call.argument("flags");
    String category = call.argument("category");
    Uri data = call.argument("data") != null ? Uri.parse((String) call.argument("data")) : null;
    Bundle arguments = convertArguments((Map<String, ?>) call.argument("arguments"));
    String packageName = call.argument("package");
    ComponentName componentName =
        (!TextUtils.isEmpty(packageName)
                && !TextUtils.isEmpty((String) call.argument("componentName")))
            ? new ComponentName(packageName, (String) call.argument("componentName"))
            : null;
    String type = call.argument("type");

    Intent intent =
        sender.buildIntent(
            action, flags, category, data, arguments, packageName, componentName, type);

    if ("launch".equalsIgnoreCase(call.method)) {
      sender.send(intent);

      result.success(null);
    } else if ("canResolveActivity".equalsIgnoreCase(call.method)) {
      result.success(sender.canResolveActivity(intent));
    } else {
      result.notImplemented();
    }
  }

  private static String convertAction(String action) {
    if (action == null) {
      return null;
    }

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

  private static Bundle convertArguments(Map<String, ?> arguments) {
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
        bundle.putBundle(key, convertArguments((Map<String, ?>) value));
      } else {
        throw new UnsupportedOperationException("Unsupported type " + value);
      }
    }
    return bundle;
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
