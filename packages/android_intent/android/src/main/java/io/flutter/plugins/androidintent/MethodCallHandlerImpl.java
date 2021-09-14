// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    String action = convertAction((String) call.argument("action"));
    Integer flags = call.argument("flags");
    String category = call.argument("category");
    String stringData = call.argument("data");
    Uri data = call.argument("data") != null ? Uri.parse(stringData) : null;
    Map<String, ?> stringMap = call.argument("arguments");
    Bundle arguments = convertArguments(stringMap);
    String packageName = call.argument("package");
    String component = call.argument("componentName");
    ComponentName componentName = null;
    if (packageName != null
        && component != null
        && !TextUtils.isEmpty(packageName)
        && !TextUtils.isEmpty(component)) {
      componentName = new ComponentName(packageName, component);
    }
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
      ArrayList<String> stringArrayList = isStringArrayList(value);
      ArrayList<Integer> integerArrayList = isIntegerArrayList(value);
      Map<String, ?> stringMap = isStringKeyedMap(value);
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
      } else if (integerArrayList != null) {
        bundle.putIntegerArrayList(key, integerArrayList);
      } else if (stringArrayList != null) {
        bundle.putStringArrayList(key, stringArrayList);
      } else if (stringMap != null) {
        bundle.putBundle(key, convertArguments(stringMap));
      } else {
        throw new UnsupportedOperationException("Unsupported type " + value);
      }
    }
    return bundle;
  }

  private static ArrayList<Integer> isIntegerArrayList(Object value) {
    ArrayList<Integer> integerArrayList = new ArrayList<>();
    if (!(value instanceof ArrayList)) {
      return null;
    }
    ArrayList<?> intList = (ArrayList<?>) value;
    for (Object o : intList) {
      if (!(o instanceof Integer)) {
        return null;
      } else {
        integerArrayList.add((Integer) o);
      }
    }
    return integerArrayList;
  }

  private static ArrayList<String> isStringArrayList(Object value) {
    ArrayList<String> stringArrayList = new ArrayList<>();
    if (!(value instanceof ArrayList)) {
      return null;
    }
    ArrayList<?> stringList = (ArrayList<?>) value;
    for (Object o : stringList) {
      if (!(o instanceof String)) {
        return null;
      } else {
        stringArrayList.add((String) o);
      }
    }
    return stringArrayList;
  }

  private static Map<String, ?> isStringKeyedMap(Object value) {
    Map<String, Object> stringMap = new HashMap<>();
    if (!(value instanceof Map)) {
      return null;
    }
    Map<?, ?> mapValue = (Map<?, ?>) value;
    for (Object key : mapValue.keySet()) {
      if (!(key instanceof String)) {
        return null;
      } else {
        Object o = mapValue.get(key);
        if (o != null) {
          stringMap.put((String) key, o);
        }
      }
    }
    return stringMap;
  }
}
