// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanager;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.Application;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;

public class AlarmService extends Service {
  public static final String TAG = "AlarmService";
  private static FlutterNativeView sSharedFlutterView;
  private static PluginRegistrantCallback sPluginRegistrantCallback;

  private FlutterNativeView mFlutterView;
  private String appBundlePath;

  public static void setOneShot(
      Context context,
      int requestCode,
      boolean exact,
      boolean wakeup,
      long startMillis,
      String entrypoint) {
    final boolean repeating = false;
    scheduleAlarm(context, requestCode, repeating, exact, wakeup, startMillis, 0, entrypoint);
  }

  public static void setPeriodic(
      Context context,
      int requestCode,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
      String entrypoint) {
    final boolean repeating = true;
    scheduleAlarm(
        context, requestCode, repeating, exact, wakeup, startMillis, intervalMillis, entrypoint);
  }

  public static void cancel(Context context, int requestCode) {
    Intent alarm = new Intent(context, AlarmService.class);
    PendingIntent existingIntent =
        PendingIntent.getService(context, requestCode, alarm, PendingIntent.FLAG_NO_CREATE);
    if (existingIntent == null) {
      Log.i(TAG, "cancel: service not found");
      return;
    }
    AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
    manager.cancel(existingIntent);
  }

  public static FlutterNativeView getSharedFlutterView() {
    return sSharedFlutterView;
  }

  public static boolean setSharedFlutterView(FlutterNativeView view) {
    if (sSharedFlutterView != null && sSharedFlutterView != view) {
      Log.i(TAG, "setSharedFlutterView tried to overwrite an existing FlutterNativeView");
      return false;
    }
    Log.i(TAG, "setSharedFlutterView set");
    sSharedFlutterView = view;
    return true;
  }

  public static void setPluginRegistrant(PluginRegistrantCallback callback) {
    sPluginRegistrantCallback = callback;
  }

  private void ensureFlutterView() {
    if (mFlutterView != null) {
      return;
    }

    if (sSharedFlutterView != null) {
      mFlutterView = sSharedFlutterView;
      return;
    }

    // mFlutterView and sSharedFlutterView are both null. That likely means that
    // no FlutterView has ever been created in this process before. So, we'll
    // make one, and assign it to both mFlutterView and sSharedFlutterView.
    mFlutterView = new FlutterNativeView(getApplicationContext());
    sSharedFlutterView = mFlutterView;

    // If there was no FlutterNativeView before now, then we also must
    // initialize the PluginRegistry.
    sPluginRegistrantCallback.registerWith(mFlutterView.getPluginRegistry());
    return;
  }

  // This returns the FlutterView for the main FlutterActivity if there is one.
  private static FlutterNativeView viewFromAppContext(Context context) {
    Application app = (Application) context;
    if (!(app instanceof FlutterApplication)) {
      Log.i(TAG, "viewFromAppContext app not a FlutterApplication");
      return null;
    }
    FlutterApplication flutterApp = (FlutterApplication) app;
    Activity activity = flutterApp.getCurrentActivity();
    if (activity == null) {
      Log.i(TAG, "viewFromAppContext activity is null");
      return null;
    }
    if (!(activity instanceof FlutterActivity)) {
      Log.i(TAG, "viewFromAppContext activity is not a FlutterActivity");
      return null;
    }
    FlutterActivity flutterActivity = (FlutterActivity) activity;
    return flutterActivity.getFlutterView().getFlutterNativeView();
  }

  @Override
  public void onCreate() {
    super.onCreate();
    Context context = getApplicationContext();
    mFlutterView = viewFromAppContext(context);
    FlutterMain.ensureInitializationComplete(context, null);
    if (appBundlePath == null) {
      appBundlePath = FlutterMain.findAppBundlePath(context);
    }
  }

  @Override
  public void onDestroy() {
    // Try to find the native view of the main activity if there is one.
    Context context = getApplicationContext();
    FlutterNativeView nativeView = viewFromAppContext(context);

    // Don't destroy mFlutterView if it is the same as the native view for the
    // main activity, or the same as the shared native view.
    if (mFlutterView != nativeView && mFlutterView != sSharedFlutterView) {
      mFlutterView.destroy();
    }
    mFlutterView = null;

    // Don't destroy the shared native view if it is the same native view as
    // for the main activity.
    if (sSharedFlutterView != nativeView) {
      sSharedFlutterView.destroy();
    }
    sSharedFlutterView = null;
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    ensureFlutterView();
    String entrypoint = intent.getStringExtra("entrypoint");
    if (entrypoint == null) {
      Log.i(TAG, "onStartCommand got a null entrypoint. Bailing out");
      return START_NOT_STICKY;
    }
    if (appBundlePath != null) {
      mFlutterView.runFromBundle(appBundlePath, null, entrypoint, true);
    }
    return START_NOT_STICKY;
  }

  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }

  private static void scheduleAlarm(
      Context context,
      int requestCode,
      boolean repeating,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
      String entrypoint) {
    // Create an Intent for the alarm and set the desired Dart entrypoint.
    Intent alarm = new Intent(context, AlarmService.class);
    alarm.putExtra("entrypoint", entrypoint);
    PendingIntent pendingIntent =
        PendingIntent.getService(context, requestCode, alarm, PendingIntent.FLAG_UPDATE_CURRENT);

    // Use the appropriate clock.
    int clock = AlarmManager.RTC;
    if (wakeup) {
      clock = AlarmManager.RTC_WAKEUP;
    }

    // Schedule the alarm.
    AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
    if (exact) {
      if (repeating) {
        manager.setRepeating(clock, startMillis, intervalMillis, pendingIntent);
      } else {
        manager.setExact(clock, startMillis, pendingIntent);
      }
    } else {
      if (repeating) {
        manager.setInexactRepeating(clock, startMillis, intervalMillis, pendingIntent);
      } else {
        manager.set(clock, startMillis, pendingIntent);
      }
    }
  }
}
