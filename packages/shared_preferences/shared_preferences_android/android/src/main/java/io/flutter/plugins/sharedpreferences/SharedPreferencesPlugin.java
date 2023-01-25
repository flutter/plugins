// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.sharedpreferences.Messages.SharedPreferencesApi;
import java.util.List;
import java.util.Map;

/** SharedPreferencesPlugin */
public class SharedPreferencesPlugin implements FlutterPlugin, SharedPreferencesApi {
  final String TAG = "SharedPreferencesPlugin.java";

  // SharedPreferences Helper Object, exposes SharedPreferences methods
  private MethodCallHandlerImpl preferences;

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    final SharedPreferencesPlugin plugin = new SharedPreferencesPlugin();
    plugin.setup(registrar.messenger(), registrar.context());
  }

  @SuppressLint("LongLogTag")
  private void setup(BinaryMessenger messenger, Context context) {
    preferences = new MethodCallHandlerImpl(context);
    try {
      SharedPreferencesApi.setup(messenger, this);
    } catch (Exception ex) {
      Log.e(TAG, "Received exception while setting up SharedPreferencesPlugin", ex);
    }
  }

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    setup(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    SharedPreferencesApi.setup(binding.getBinaryMessenger(), null);
  }

  @Override
  public Boolean setBool(String key, Boolean value) {
    return preferences.setBool(key, value);
  }

  @Override
  public Boolean setString(String key, String value) {
    return preferences.setString(key, value);
  }

  @Override
  public Boolean setInt(String key, Object value) {
    return preferences.setInt(key, value);
  }

  @Override
  public Boolean setDouble(String key, Double value) {
    return preferences.setDouble(key, value);
  }

  @Override
  public Boolean remove(String key) {
    return preferences.remove(key);
  }

  @Override
  public Boolean setStringList(String key, List<String> value) throws RuntimeException {
    return preferences.setStringList(key, value);
  }

  @Override
  public Map<String, Object> getAll() throws RuntimeException {
    return preferences.getAll();
  }

  @Override
  public Boolean clear() throws RuntimeException {
    return preferences.clear();
  }
}
