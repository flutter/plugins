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
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterIsolateStartedEvent;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import java.util.concurrent.atomic.AtomicBoolean;

public class AlarmService extends Service {
  public static final String TAG = "AlarmService";
  private static AtomicBoolean sStarted;
  private static FlutterNativeView sSharedFlutterView;
  private static MethodChannel sBackgroundChannel;
  private static OnStartedCallback sOnStartedCallback;
  private static PluginRegistrantCallback sPluginRegistrantCallback;

  private String mAppBundlePath;

  private static class OnStartedCallback implements FlutterIsolateStartedEvent {
    public void onStarted(boolean success) {
      if (!success) {
        Log.e(TAG, "AlarmService start failed. Bailing out.");
        return;
      }
      sStarted.set(true);
    }
  }

  public static void startAlarmService(Context context, String entrypoint,
                                       String libraryPath) {
    FlutterMain.ensureInitializationComplete(context, null);
    String mAppBundlePath = FlutterMain.findAppBundlePath(context);
    sSharedFlutterView = new FlutterNativeView(context, true);
    sStarted = new AtomicBoolean(false);
    if (mAppBundlePath != null && !sStarted.get()) {
      Log.i(TAG, "Starting AlarmService...");
      sOnStartedCallback = new OnStartedCallback();
      sSharedFlutterView.runFromBundle(mAppBundlePath, null, entrypoint,
                                       libraryPath, false, sOnStartedCallback);
      sPluginRegistrantCallback.registerWith(
          sSharedFlutterView.getPluginRegistry());
    }
  }

  public static void setBackgroundChannel(MethodChannel channel) {
    sBackgroundChannel = channel;
  }

  public static void setOneShot(Context context, int requestCode, boolean exact,
                                boolean wakeup, long startMillis,
                                String entrypoint, String className,
                                String libraryPath) {
    final boolean repeating = false;
    scheduleAlarm(context, requestCode, repeating, exact, wakeup, startMillis,
                  0, entrypoint, className, libraryPath);
  }

  public static void setPeriodic(Context context, int requestCode,
                                 boolean exact, boolean wakeup,
                                 long startMillis, long intervalMillis,
                                 String entrypoint, String className,
                                 String libraryPath) {
    final boolean repeating = true;
    scheduleAlarm(context, requestCode, repeating, exact, wakeup, startMillis,
                  intervalMillis, entrypoint, className, libraryPath);
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
    sSharedFlutterView = view;
    return true;
  }

  public static void setPluginRegistrant(PluginRegistrantCallback callback) {
    sPluginRegistrantCallback = callback;
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
    FlutterMain.ensureInitializationComplete(context, null);
    mAppBundlePath = FlutterMain.findAppBundlePath(context);
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    if (!sStarted.get()) {
      Log.i(TAG, "AlarmService has not yet started.");
      // TODO(bkonyi): queue up alarm events.
      return START_NOT_STICKY;
    }
    String entrypoint = intent.getStringExtra("entrypoint");
    String className = intent.getStringExtra("className");
    String libraryPath = intent.getStringExtra("libraryPath");
    if (entrypoint == null) {
      Log.e(TAG, "onStartCommand got a null entrypoint. Bailing out.");
      return START_NOT_STICKY;
    }
    if (sBackgroundChannel == null) {
      Log.e(TAG,
            "setBackgroundChannel was not called before alarms were scheduled."
                + " Bailing out.");
      return START_NOT_STICKY;
    }
    sBackgroundChannel.invokeMethod(
        "", new Object[] {entrypoint, libraryPath, className});
    return START_NOT_STICKY;
  }

  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }

  private static void scheduleAlarm(Context context, int requestCode,
                                    boolean repeating, boolean exact,
                                    boolean wakeup, long startMillis,
                                    long intervalMillis, String entrypoint,
                                    String className, String libraryPath) {
    // Create an Intent for the alarm and set the desired Dart entrypoint.
    Intent alarm = new Intent(context, AlarmService.class);
    alarm.putExtra("entrypoint", entrypoint);
    alarm.putExtra("className", className);
    alarm.putExtra("libraryPath", libraryPath);
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
