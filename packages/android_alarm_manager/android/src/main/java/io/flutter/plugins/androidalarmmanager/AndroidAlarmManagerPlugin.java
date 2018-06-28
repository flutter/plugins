// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanager;

import android.content.Context;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.ViewDestroyListener;
import io.flutter.view.FlutterNativeView;
import org.json.JSONArray;
import org.json.JSONException;

/** AndroidAlarmManagerPlugin */
public class AndroidAlarmManagerPlugin implements MethodCallHandler, ViewDestroyListener {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(
            registrar.messenger(),
            "plugins.flutter.io/android_alarm_manager",
            JSONMethodCodec.INSTANCE);
    final MethodChannel backgroundChannel =
        new MethodChannel(registrar.messenger(),
                          "plugins.flutter.io/android_alarm_manager_background",
                          JSONMethodCodec.INSTANCE);
    AndroidAlarmManagerPlugin plugin = new AndroidAlarmManagerPlugin(registrar.context());
    channel.setMethodCallHandler(plugin);
    backgroundChannel.setMethodCallHandler(plugin);
    registrar.addViewDestroyListener(plugin);
    AlarmService.setBackgroundChannel(backgroundChannel);
  }

  private Context mContext;

  private AndroidAlarmManagerPlugin(Context context) {
    this.mContext = context;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    Object arguments = call.arguments;
    try {
      if (method.equals("AlarmService.start")) {
        startService((JSONArray)arguments);
        result.success(true);
      } else if (method.equals("Alarm.periodic")) {
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

  private void startService(JSONArray arguments) throws JSONException {
    String entrypoint = arguments.getString(0);
    String libraryPath = arguments.getString(1);
    AlarmService.startAlarmService(mContext, entrypoint, libraryPath);
  }

  private void oneShot(JSONArray arguments) throws JSONException {
    int requestCode = arguments.getInt(0);
    boolean exact = arguments.getBoolean(1);
    boolean wakeup = arguments.getBoolean(2);
    long startMillis = arguments.getLong(3);
    String entrypoint = arguments.getString(4);

    // JSONArray.getString will coerce null to "null".
    String className = null;
    if (!arguments.get(5).equals(null)) {
      className = arguments.getString(5);
    }
    String libraryPath = null;
    if (!arguments.get(6).equals(null)) {
      libraryPath = arguments.getString(6);
    }
    AlarmService.setOneShot(mContext, requestCode, exact, wakeup, startMillis,
                            entrypoint, className, libraryPath);
  }

  private void periodic(JSONArray arguments) throws JSONException {
    int requestCode = arguments.getInt(0);
    boolean exact = arguments.getBoolean(1);
    boolean wakeup = arguments.getBoolean(2);
    long startMillis = arguments.getLong(3);
    long intervalMillis = arguments.getLong(4);
    String entrypoint = arguments.getString(5);

    // JSONArray.getString will coerce null to "null".
    String className = null;
    if (!arguments.get(6).equals(null)) {
      className = arguments.getString(6);
    }
    String libraryPath = null;
    if (!arguments.get(7).equals(null)) {
      libraryPath = arguments.getString(7);
    }
    AlarmService.setPeriodic(mContext, requestCode, exact, wakeup, startMillis,
                             intervalMillis, entrypoint, className,
                             libraryPath);
  }

  private void cancel(JSONArray arguments) throws JSONException {
    int requestCode = arguments.getInt(0);
    AlarmService.cancel(mContext, requestCode);
  }

  @Override
  public boolean onViewDestroy(FlutterNativeView nativeView) {
    return AlarmService.setSharedFlutterView(nativeView);
  }
}
