// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.androidalarmmanager;

import android.app.Activity;
import android.content.Context;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import org.json.JSONArray;
import org.json.JSONException;

/** AndroidAlarmManagerPlugin */
public class AndroidAlarmManagerPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(
            registrar.messenger(),
            "plugins.flutter.io/android_alarm_manager",
            JSONMethodCodec.INSTANCE);
    channel.setMethodCallHandler(new AndroidAlarmManagerPlugin(registrar.activity()));
  }

  private Context mContext;

  private AndroidAlarmManagerPlugin(Activity activity) {
    this.mContext = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    Object arguments = call.arguments;
    try {
      if (method.equals("Alarm.periodic")) {
        periodic((JSONArray) arguments);
        result.success(true);
      } else if (method.equals("Alarm.oneShot")) {
        oneShot((JSONArray) arguments);
        result.success(true);
      } else if (method.equals("Alarm.cancel")) {
        cancel((JSONArray) arguments);
        result.success(true);
      } else {
        result.notImplemented();
      }
    } catch (JSONException e) {
      result.error("error", "JSON error: " + e.getMessage(), null);
    }
  }

  private void oneShot(JSONArray arguments) throws JSONException {
    int requestCode = arguments.getInt(0);
    boolean exact = arguments.getBoolean(1);
    boolean wakeup = arguments.getBoolean(2);
    long startMillis = arguments.getLong(3);
    String entrypoint = arguments.getString(4);
    AlarmService.setOneShot(mContext, requestCode, exact, wakeup, startMillis, entrypoint);
  }

  private void periodic(JSONArray arguments) throws JSONException {
    int requestCode = arguments.getInt(0);
    boolean exact = arguments.getBoolean(1);
    boolean wakeup = arguments.getBoolean(2);
    long startMillis = arguments.getLong(3);
    long intervalMillis = arguments.getLong(4);
    String entrypoint = arguments.getString(5);
    AlarmService.setPeriodic(
        mContext, requestCode, exact, wakeup, startMillis, intervalMillis, entrypoint);
  }

  private void cancel(JSONArray arguments) throws JSONException {
    int requestCode = arguments.getInt(0);
    AlarmService.cancel(mContext, requestCode);
  }
}
