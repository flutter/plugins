// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.shared_preferences;

import android.app.Activity;
import android.content.Context;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/**
 * SharedPreferencesPlugin
 */
public class SharedPreferencesPlugin implements MethodCallHandler {
  private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
  private static final String CHANNEL_NAME = "plugins.flutter.io/shared_preferences";

  private final android.content.SharedPreferences preferences;
  private final android.content.SharedPreferences.Editor editor;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    SharedPreferencesPlugin instance = new SharedPreferencesPlugin(registrar.activity());
    channel.setMethodCallHandler(instance);
  }

  private SharedPreferencesPlugin(Activity activity) {
    preferences = activity.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    editor = preferences.edit();
  }

  // Filter preferences to only those set by the flutter app.
  private Map<String, Object> getAllPrefs() {
    Map<String, ?> allPrefs = preferences.getAll();
    Map<String, Object> filteredPrefs = new HashMap<>();
    for (String key : allPrefs.keySet()) {
      if (key.startsWith("flutter.")) {
        filteredPrefs.put(key, allPrefs.get(key));
      }
    }
    return filteredPrefs;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    String key = call.argument("key");
    switch (call.method) {
      case "setBool":
        editor.putBoolean(key, (boolean) call.argument("value")).apply();
        result.success(null);
        break;
      case "setDouble":
        editor.putFloat(key, (float) call.argument("value")).apply();
        result.success(null);
        break;
      case "setInt":
        editor.putInt(key, (int) call.argument("value")).apply();
        result.success(null);
        break;
      case "setString":
        editor.putString(key, (String) call.argument("value")).apply();
        result.success(null);
        break;
      case "setStringSet":
        editor.putStringSet(key, new HashSet<>((List<String>) call.argument("value"))).apply();
        result.success(null);
        break;
      case "commit":
        result.success(editor.commit());
        break;
      case "getAll":
        result.success(getAllPrefs());
        break;
      case "clear":
        for (String keyToDelete : getAllPrefs().keySet()) {
          editor.remove(keyToDelete);
        }
        result.success(editor.commit());
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
