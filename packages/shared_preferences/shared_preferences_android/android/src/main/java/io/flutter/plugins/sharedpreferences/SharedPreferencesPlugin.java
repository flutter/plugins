// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import android.content.SharedPreferences;


import io.flutter.plugins.sharedpreferences.Messages.SharedPreferencesApi;

/** SharedPreferencesPlugin */
public class SharedPreferencesPlugin implements FlutterPlugin , SharedPreferencesApi{


  private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

  // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
  private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
  private static final String BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy";
  private static final String DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu";

  private final android.content.SharedPreferences preferences;

  SharedPreferencesPlugin(){
      preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
  }

  // private static final String CHANNEL_NAME = "plugins.flutter.io/shared_preferences_android";
  // private MethodChannel channel;

  // private MethodCallHandlerImpl handler;

  private void setup(BinaryMessenger messenger, Context context) {
    TaskQueue taskQueue = messenger.makeBackgroundTaskQueue();

    try {
      SharedPreferencesApi.setup(messenger, this);
    } catch (Exception ex) {
      Log.e(TAG, "Received exception while setting up SharedPreferencesPlugin", ex);
    }

    // this.context = context;
  }

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    final SharedPreferencesPlugin plugin = new SharedPreferencesPlugin();
    plugin.setup(registrar.messenger(), registrar.context());
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
  public Boolean setBool(String key, Boolean value){
    return preferences.edit().putBoolean(key, value).commit();
  }
   @Override
  public Boolean setString(String key, String value){
   if (value.startsWith(LIST_IDENTIFIER)
              || value.startsWith(BIG_INTEGER_PREFIX)
              || value.startsWith(DOUBLE_PREFIX)) {
            result.error(
                "StorageError",
                "This string cannot be stored as it clashes with special identifier prefixes.",
                null);
            return false;
          }
    return preferences.edit().putString(key, value).commit();
  }

  @Override
  public Boolean setInt(String key, Object value){
     Number number =  value;
    if (number instanceof BigInteger) {
      BigInteger integerValue = (BigInteger) number;
      return preferences.edit().putString(key, BIG_INTEGER_PREFIX + integerValue.toString(Character.MAX_RADIX)).commit();
    } else {
      return preferences.edit().putLong(key, number.longValue()).commit();
    }
  }

  @Override
  public Boolean setDouble(String key, double value){
    String doubleValueStr = Double.toString(value);
    return preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr).commit();
  }

  @Override
  public Boolean setStringList(String key,List<String> value){
    return preferences.edit().putString(key, LIST_IDENTIFIER + encodeList(list)).commit();
  }



  // private void setupChannel(BinaryMessenger messenger, Context context) {
  //   channel = new MethodChannel(messenger, CHANNEL_NAME);
  //   handler = new MethodCallHandlerImpl(context);
  //   channel.setMethodCallHandler(handler);
  // }

  // private void teardownChannel() {
  //   handler.teardown();
  //   handler = null;
  //   channel.setMethodCallHandler(null);
  //   channel = null;
  // }
}
