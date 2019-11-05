// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanager;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Handler;
import android.util.Log;
import androidx.core.app.AlarmManagerCompat;
import androidx.core.app.JobIntentService;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;
import org.json.JSONException;
import org.json.JSONObject;

public class AlarmService extends JobIntentService {
  private static final String TAG = "AlarmService";
  private static final String PERSISTENT_ALARMS_SET_KEY = "persistent_alarm_ids";
  protected static final String SHARED_PREFERENCES_KEY = "io.flutter.android_alarm_manager_plugin";
  private static final int JOB_ID = 1984; // Random job ID.
  private static final Object persistentAlarmsLock = new Object();

  // TODO(mattcarroll): make alarmQueue per-instance, not static.
  private static List<Intent> alarmQueue = Collections.synchronizedList(new LinkedList<Intent>());

  /** Background Dart execution context. */
  private static BackgroundExecutionContext backgroundExecutionContext;

  // Schedule the alarm to be handled by the AlarmService.
  public static void enqueueAlarmProcessing(Context context, Intent alarmContext) {
    enqueueWork(context, AlarmService.class, JOB_ID, alarmContext);
  }

  public static void startBackgroundIsolate(Context context, long callbackHandle) {
    assert(backgroundExecutionContext == null);
    backgroundExecutionContext = new BackgroundExecutionContext();
    backgroundExecutionContext.startBackgroundIsolate(context, callbackHandle);
  }

  /**
   * Called once the Dart isolate ({@code backgroundFlutterView}) has finished initializing.
   *
   * <p>Invoked by {@link AndroidAlarmManagerPlugin} when it receives the {@code
   * AlarmService.initialized} message. Processes all alarm events that came in while the isolate
   * was starting.
   */
  static void onInitialized() {
    Log.i(TAG, "AlarmService started!");
    synchronized (alarmQueue) {
      // Handle all the alarm events received before the Dart isolate was
      // initialized, then clear the queue.
      Iterator<Intent> i = alarmQueue.iterator();
      while (i.hasNext()) {
        backgroundExecutionContext.executeDartCallbackInBackgroundIsolate(i.next(), null);
      }
      alarmQueue.clear();
    }
  }

  /**
   * Sets the Dart callback handle for the Dart method that is responsible for initializing the
   * background Dart isolate, preparing it to receive Dart callback tasks requests.
   */
  public static void setCallbackDispatcher(Context context, long callbackHandle) {
    BackgroundExecutionContext.setCallbackDispatcher(context, callbackHandle);
  }

  public static void setPluginRegistrant(PluginRegistrantCallback callback) {
    // Indirectly set in BackgroundExecutionContext for backwards compatibility.
    BackgroundExecutionContext.setPluginRegistrant(callback);
  }

  private static void scheduleAlarm(
      Context context,
      int requestCode,
      boolean alarmClock,
      boolean allowWhileIdle,
      boolean repeating,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
      boolean rescheduleOnReboot,
      long callbackHandle) {
    if (rescheduleOnReboot) {
      addPersistentAlarm(
          context,
          requestCode,
          alarmClock,
          allowWhileIdle,
          repeating,
          exact,
          wakeup,
          startMillis,
          intervalMillis,
          callbackHandle);
    }

    // Create an Intent for the alarm and set the desired Dart callback handle.
    Intent alarm = new Intent(context, AlarmBroadcastReceiver.class);
    alarm.putExtra("id", requestCode);
    alarm.putExtra("callbackHandle", callbackHandle);
    PendingIntent pendingIntent =
        PendingIntent.getBroadcast(context, requestCode, alarm, PendingIntent.FLAG_UPDATE_CURRENT);

    // Use the appropriate clock.
    int clock = AlarmManager.RTC;
    if (wakeup) {
      clock = AlarmManager.RTC_WAKEUP;
    }

    // Schedule the alarm.
    AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

    if (alarmClock) {
      AlarmManagerCompat.setAlarmClock(manager, startMillis, pendingIntent, pendingIntent);
      return;
    }

    if (exact) {
      if (repeating) {
        manager.setRepeating(clock, startMillis, intervalMillis, pendingIntent);
      } else {
        if (allowWhileIdle) {
          AlarmManagerCompat.setExactAndAllowWhileIdle(manager, clock, startMillis, pendingIntent);
        } else {
          AlarmManagerCompat.setExact(manager, clock, startMillis, pendingIntent);
        }
      }
    } else {
      if (repeating) {
        manager.setInexactRepeating(clock, startMillis, intervalMillis, pendingIntent);
      } else {
        if (allowWhileIdle) {
          AlarmManagerCompat.setAndAllowWhileIdle(manager, clock, startMillis, pendingIntent);
        } else {
          manager.set(clock, startMillis, pendingIntent);
        }
      }
    }
  }

  public static void setOneShot(Context context, AndroidAlarmManagerPlugin.OneShotRequest request) {
    final boolean repeating = false;
    scheduleAlarm(
        context,
        request.requestCode,
        request.alarmClock,
        request.allowWhileIdle,
        repeating,
        request.exact,
        request.wakeup,
        request.startMillis,
        0,
        request.rescheduleOnReboot,
        request.callbackHandle);
  }

  public static void setPeriodic(
      Context context, AndroidAlarmManagerPlugin.PeriodicRequest request) {
    final boolean repeating = true;
    final boolean allowWhileIdle = false;
    final boolean alarmClock = false;
    scheduleAlarm(
        context,
        request.requestCode,
        alarmClock,
        allowWhileIdle,
        repeating,
        request.exact,
        request.wakeup,
        request.startMillis,
        request.intervalMillis,
        request.rescheduleOnReboot,
        request.callbackHandle);
  }

  public static void cancel(Context context, int requestCode) {
    // Clear the alarm if it was set to be rescheduled after reboots.
    clearPersistentAlarm(context, requestCode);

    // Cancel the alarm with the system alarm service.
    Intent alarm = new Intent(context, AlarmBroadcastReceiver.class);
    PendingIntent existingIntent =
        PendingIntent.getBroadcast(context, requestCode, alarm, PendingIntent.FLAG_NO_CREATE);
    if (existingIntent == null) {
      Log.i(TAG, "cancel: broadcast receiver not found");
      return;
    }
    AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
    manager.cancel(existingIntent);
  }

  private static String getPersistentAlarmKey(int requestCode) {
    return "android_alarm_manager/persistent_alarm_" + Integer.toString(requestCode);
  }

  private static void addPersistentAlarm(
      Context context,
      int requestCode,
      boolean alarmClock,
      boolean allowWhileIdle,
      boolean repeating,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
      long callbackHandle) {
    HashMap<String, Object> alarmSettings = new HashMap<>();
    alarmSettings.put("alarmClock", alarmClock);
    alarmSettings.put("allowWhileIdle", allowWhileIdle);
    alarmSettings.put("repeating", repeating);
    alarmSettings.put("exact", exact);
    alarmSettings.put("wakeup", wakeup);
    alarmSettings.put("startMillis", startMillis);
    alarmSettings.put("intervalMillis", intervalMillis);
    alarmSettings.put("callbackHandle", callbackHandle);
    JSONObject obj = new JSONObject(alarmSettings);
    String key = getPersistentAlarmKey(requestCode);
    SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);

    synchronized (persistentAlarmsLock) {
      Set<String> persistentAlarms = prefs.getStringSet(PERSISTENT_ALARMS_SET_KEY, null);
      if (persistentAlarms == null) {
        persistentAlarms = new HashSet<>();
      }
      if (persistentAlarms.isEmpty()) {
        RebootBroadcastReceiver.enableRescheduleOnReboot(context);
      }
      persistentAlarms.add(Integer.toString(requestCode));
      prefs
          .edit()
          .putString(key, obj.toString())
          .putStringSet(PERSISTENT_ALARMS_SET_KEY, persistentAlarms)
          .apply();
    }
  }

  private static void clearPersistentAlarm(Context context, int requestCode) {
    SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    synchronized (persistentAlarmsLock) {
      Set<String> persistentAlarms = p.getStringSet(PERSISTENT_ALARMS_SET_KEY, null);
      if ((persistentAlarms == null) || !persistentAlarms.contains(requestCode)) {
        return;
      }
      persistentAlarms.remove(requestCode);
      String key = getPersistentAlarmKey(requestCode);
      p.edit().remove(key).putStringSet(PERSISTENT_ALARMS_SET_KEY, persistentAlarms).apply();

      if (persistentAlarms.isEmpty()) {
        RebootBroadcastReceiver.disableRescheduleOnReboot(context);
      }
    }
  }

  public static void reschedulePersistentAlarms(Context context) {
    synchronized (persistentAlarmsLock) {
      SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
      Set<String> persistentAlarms = p.getStringSet(PERSISTENT_ALARMS_SET_KEY, null);
      // No alarms to reschedule.
      if (persistentAlarms == null) {
        return;
      }

      Iterator<String> it = persistentAlarms.iterator();
      while (it.hasNext()) {
        int requestCode = Integer.parseInt(it.next());
        String key = getPersistentAlarmKey(requestCode);
        String json = p.getString(key, null);
        if (json == null) {
          Log.e(
              TAG, "Data for alarm request code " + Integer.toString(requestCode) + " is invalid.");
          continue;
        }
        try {
          JSONObject alarm = new JSONObject(json);
          boolean alarmClock = alarm.getBoolean("alarmClock");
          boolean allowWhileIdle = alarm.getBoolean("allowWhileIdle");
          boolean repeating = alarm.getBoolean("repeating");
          boolean exact = alarm.getBoolean("exact");
          boolean wakeup = alarm.getBoolean("wakeup");
          long startMillis = alarm.getLong("startMillis");
          long intervalMillis = alarm.getLong("intervalMillis");
          long callbackHandle = alarm.getLong("callbackHandle");
          scheduleAlarm(
              context,
              requestCode,
              alarmClock,
              allowWhileIdle,
              repeating,
              exact,
              wakeup,
              startMillis,
              intervalMillis,
              false,
              callbackHandle);
        } catch (JSONException e) {
          Log.e(TAG, "Data for alarm request code " + requestCode + " is invalid: " + json);
        }
      }
    }
  }

  @Override
  public void onCreate() {
    super.onCreate();
    if (backgroundExecutionContext == null) {
      backgroundExecutionContext = new BackgroundExecutionContext();
    }
    Context context = getApplicationContext();
    backgroundExecutionContext.startBackgroundIsolate(context);
  }

  /**
   * Executes a Dart callback, as specified within the incoming {@code intent}.
   *
   * <p>Invoked by our {@link JobIntentService} superclass after a call to {@link
   * JobIntentService#enqueueWork(Context, Class, int, Intent);}.
   *
   * <p>If there are no pre-existing callback execution requests, other than the incoming {@code
   * intent}, then the desired Dart callback is invoked immediately.
   *
   * <p>If there are any pre-existing callback requests that have yet to be executed, the incoming
   * {@code intent} is added to the {@link #alarmQueue} to invoked later, after all pre-existing
   * callbacks have been executed.
   */
  @Override
  protected void onHandleWork(final Intent intent) {
    // If we're in the middle of processing queued alarms, add the incoming
    // intent to the queue and return.
    synchronized (alarmQueue) {
      if (!backgroundExecutionContext.isRunning()) {
        Log.i(TAG, "AlarmService has not yet started.");
        alarmQueue.add(intent);
        return;
      }
    }

    // There were no pre-existing callback requests. Execute the callback
    // specified by the incoming intent.
    final CountDownLatch latch = new CountDownLatch(1);
    new Handler(getMainLooper())
        .post(
            new Runnable() {
              @Override
              public void run() {
                backgroundExecutionContext.executeDartCallbackInBackgroundIsolate(intent, latch);
              }
            });

    try {
      latch.await();
    } catch (InterruptedException ex) {
      Log.i(TAG, "Exception waiting to execute Dart callback", ex);
    }
  }
}
