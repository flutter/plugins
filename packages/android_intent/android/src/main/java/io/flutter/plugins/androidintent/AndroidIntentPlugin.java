// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidintent;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.ArrayList;
import java.util.Map;

/** AndroidIntentPlugin */
@SuppressWarnings("unchecked")
public class AndroidIntentPlugin implements MethodCallHandler {
  private static final String TAG = AndroidIntentPlugin.class.getCanonicalName();
  private final Registrar mRegistrar;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/android_intent");
    channel.setMethodCallHandler(new AndroidIntentPlugin(registrar));
  }

  private AndroidIntentPlugin(Registrar registrar) {
    this.mRegistrar = registrar;
  }

  private String convertAction(String action) {
    switch (action) {
      case "action_view":
        return Intent.ACTION_VIEW;
      case "action_voice":
        return Intent.ACTION_VOICE_COMMAND;
      case "settings":
        return Settings.ACTION_SETTINGS;
      case "action_location_source_settings":
        return Settings.ACTION_LOCATION_SOURCE_SETTINGS;
      case "action_add_account":
        return Settings.ACTION_ADD_ACCOUNT;
      case "action_apn_settings":
        return Settings.ACTION_APN_SETTINGS;
      case "action_accessibility_settings":
        return Settings.ACTION_ACCESSIBILITY_SETTINGS;
      case "action_airplane_mode_settings":
        return Settings.ACTION_AIRPLANE_MODE_SETTINGS;
      case "action_application_development_settings":
        return Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS;
      case "action_application_settings":
        return Settings.ACTION_APPLICATION_SETTINGS;
      case "action_app_notification_settings":
        return Settings.ACTION_APP_NOTIFICATION_SETTINGS;
      case "action_data_usage_settings":
        return Settings.ACTION_DATA_USAGE_SETTINGS;
      case "action_battery_saver_settings":
        return Settings.ACTION_BATTERY_SAVER_SETTINGS;
      case "action_bluetooth_settings":
        return Settings.ACTION_BLUETOOTH_SETTINGS;
      case "action_captioning_settings":
        return Settings.ACTION_CAPTIONING_SETTINGS;
      case "action_cast_settings":
        return Settings.ACTION_CAST_SETTINGS;
      case "action_channel_notification_settings":
        return Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS;
      case "action_data_roaming_settings":
        return Settings.ACTION_DATA_ROAMING_SETTINGS;
      case "action_date_settings":
        return Settings.ACTION_DATE_SETTINGS;
      case "action_device_info_settings":
        return Settings.ACTION_DEVICE_INFO_SETTINGS;
      case "action_display_settings":
        return Settings.ACTION_DISPLAY_SETTINGS;
      case "action_dream_settings":
        return Settings.ACTION_DREAM_SETTINGS;
      case "action_fingerprint_enroll":
        return Settings.ACTION_FINGERPRINT_ENROLL;
      case "action_hard_keyboard_settings":
        return Settings.ACTION_HARD_KEYBOARD_SETTINGS;
      case "action_home_settings":
        return Settings.ACTION_HOME_SETTINGS;
      case "action_ignore_background_data_restrictions_settings":
        return Settings.ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS;
      case "action_ignore_battery_optimization_settings":
        return Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS;
      case "action_input_method_settings":
        return Settings.ACTION_INPUT_METHOD_SETTINGS;
      case "action_input_method_subtype_settings":
        return Settings.ACTION_INPUT_METHOD_SUBTYPE_SETTINGS;
      case "action_internal_storage_settings":
        return Settings.ACTION_INTERNAL_STORAGE_SETTINGS;
      case "action_locale_settings":
        return Settings.ACTION_LOCALE_SETTINGS;
      case "action_manage_all_applications_settings":
        return Settings.ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS;
      default:
        return action;
    }
  }

  private Bundle convertArguments(Map<String, ?> arguments) {
    Bundle bundle = new Bundle();
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

  private boolean isTypedArrayList(Object value, Class<?> type) {
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

  private boolean isStringKeyedMap(Object value) {
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

  private Context getActiveContext() {
    return (mRegistrar.activity() != null) ? mRegistrar.activity() : mRegistrar.context();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    Context context = getActiveContext();
    String action = convertAction((String) call.argument("action"));

    // Build intent
    Intent intent = new Intent(action);
    if (mRegistrar.activity() == null) {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    }
    if (call.argument("category") != null) {
      intent.addCategory((String) call.argument("category"));
    }
    if (call.argument("data") != null) {
      intent.setData(Uri.parse((String) call.argument("data")));
    }
    if (call.argument("arguments") != null) {
      intent.putExtras(convertArguments((Map) call.argument("arguments")));
    }
    if (call.argument("package") != null) {
      String packageName = (String) call.argument("package");
      intent.setPackage(packageName);
      if (call.argument("componentName") != null) {
        intent.setComponent(
            new ComponentName(packageName, (String) call.argument("componentName")));
      }
      if (intent.resolveActivity(context.getPackageManager()) == null) {
        Log.i(TAG, "Cannot resolve explicit intent - ignoring package");
        intent.setPackage(null);
      }
    }

    Log.i(TAG, "Sending intent " + intent);
    context.startActivity(intent);

    result.success(null);
  }
}
