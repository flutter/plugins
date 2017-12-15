// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.androidalarmmanager;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;

public class AlarmService extends Service {
  public static final String TAG = "AlarmService";

  private FlutterView flutterView;
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

  @Override
  public void onCreate() {
    Context context = getApplicationContext();
    super.onCreate();
    FlutterMain.ensureInitializationComplete(context, null);
    if (flutterView == null) {
      flutterView = new FlutterView(context);
    }
    if (appBundlePath == null) {
      appBundlePath = FlutterMain.findAppBundlePath(context);
    }
  }

  @Override
  public void onDestroy() {
    if (flutterView != null) {
      flutterView.destroy();
    }
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    String entrypoint = intent.getStringExtra("entrypoint");
    if (entrypoint == null) {
      Log.i(TAG, "onStartCommand got a null entrypoint. Bailing out");
      return START_NOT_STICKY;
    }
    if (appBundlePath != null) {
      flutterView.runFromBundle(appBundlePath, null, entrypoint, true);
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
