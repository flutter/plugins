// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanager;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
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
import java.util.concurrent.atomic.AtomicBoolean;
import org.json.JSONException;
import org.json.JSONObject;

public class AlarmService extends JobIntentService {
  public static final String TAG = "AlarmService";
  private static final String CALLBACK_HANDLE_KEY = "callback_handle";
  private static final String PERSISTENT_ALARMS_SET_KEY = "persistent_alarm_ids";
  private static final String SHARED_PREFERENCES_KEY = "io.flutter.android_alarm_manager_plugin";
  private static final int JOB_ID = 1984; // Random job ID.
  private static final Object sPersistentAlarmsLock = new Object();
  private static AtomicBoolean sStarted = new AtomicBoolean(false);
  private static List<Intent> sAlarmQueue = Collections.synchronizedList(new LinkedList<Intent>());
  private static FlutterNativeView sBackgroundFlutterView;
  private static MethodChannel sBackgroundChannel;
  private static PluginRegistrantCallback sPluginRegistrantCallback;

  private String mAppBundlePath;

  @Override
  public void onCreate() {
    super.onCreate();
    Context context = getApplicationContext();
    FlutterMain.ensureInitializationComplete(context, null);
    mAppBundlePath = FlutterMain.findAppBundlePath(context);
    if (!sStarted.get()) {
      SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
      long callbackHandle = p.getLong(CALLBACK_HANDLE_KEY, 0);
      startAlarmService(context, callbackHandle);
    }
  }

  // Schedule the alarm to be handled by the AlarmService.
  public static void enqueueAlarmProcessing(Context context, Intent alarmContext) {
    enqueueWork(context, AlarmService.class, JOB_ID, alarmContext);
  }

  // Called once the Dart isolate (sBackgroundFlutterView) has finished
  // initializing. Processes all alarm events that came in while the isolate
  // was starting.
  public static void onInitialized() {
    Log.i(TAG, "AlarmService started!");
    sStarted.set(true);
    synchronized (sAlarmQueue) {
      // Handle all the alarm events received before the Dart isolate was fully
      // initialized and clear the queue.
      Iterator<Intent> i = sAlarmQueue.iterator();
      while (i.hasNext()) {
        invokeCallbackDispatcher(i.next());
      }
      sAlarmQueue.clear();
    }
  }

  // Here we start the AlarmService. This method does a few things:
  //   - Retrieves the callback information for the handle associated with the
  //     callback dispatcher in the Dart portion of the plugin.
  //   - Builds the arguments object for running in a new FlutterNativeView.
  //   - Enters the isolate owned by the FlutterNativeView at the callback
  //     represented by `callbackHandle` and initializes the callback
  //     dispatcher.
  //   - Registers the FlutterNativeView's PluginRegistry to receive
  //     MethodChannel messages.
  public static void startAlarmService(Context context, long callbackHandle) {
    FlutterMain.ensureInitializationComplete(context, null);
    String mAppBundlePath = FlutterMain.findAppBundlePath(context);
    FlutterCallbackInformation cb =
        FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
    if (cb == null) {
      Log.e(TAG, "Fatal: failed to find callback");
      return;
    }

    // Note that we're passing `true` as the second argument to our
    // FlutterNativeView constructor. This specifies the FlutterNativeView
    // as a background view and does not create a drawing surface.
    sBackgroundFlutterView = new FlutterNativeView(context, true);
    if (mAppBundlePath != null && !sStarted.get()) {
      if (sPluginRegistrantCallback == null) {
        throw new PluginRegistrantException();
      }
      Log.i(TAG, "Starting AlarmService...");
      FlutterRunArguments args = new FlutterRunArguments();
      args.bundlePath = mAppBundlePath;
      args.entrypoint = cb.callbackName;
      args.libraryPath = cb.callbackLibraryPath;
      sBackgroundFlutterView.runFromBundle(args);
      sPluginRegistrantCallback.registerWith(sBackgroundFlutterView.getPluginRegistry());
    }
  }

  public static void setBackgroundChannel(MethodChannel channel) {
    sBackgroundChannel = channel;
  }

  public static void setCallbackDispatcher(Context context, long callbackHandle) {
    SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    p.edit().putLong(CALLBACK_HANDLE_KEY, callbackHandle).apply();
  }

  public static boolean setBackgroundFlutterView(FlutterNativeView view) {
    if (sBackgroundFlutterView != null && sBackgroundFlutterView != view) {
      Log.i(TAG, "setBackgroundFlutterView tried to overwrite an existing FlutterNativeView");
      return false;
    }
    sBackgroundFlutterView = view;
    return true;
  }

  public static void setPluginRegistrant(PluginRegistrantCallback callback) {
    sPluginRegistrantCallback = callback;
  }

  @Override
  protected void onHandleWork(Intent intent) {
    // If we're in the middle of processing queued alarms, block until they're
    // done before processing new alarms.
    synchronized (sAlarmQueue) {
      if (!sStarted.get()) {
        Log.i(TAG, "AlarmService has not yet started.");
        sAlarmQueue.add(intent);
        return;
      }
    }
    invokeCallbackDispatcher(intent);
  }

  // This is where we handle alarm events before sending them to our callback
  // dispatcher in Dart.
  private static void invokeCallbackDispatcher(Intent intent) {
    // Grab the handle for the callback associated with this alarm. Pay close
    // attention to the type of the callback handle as storing this value in a
    // variable of the wrong size will cause the callback lookup to fail.
    long callbackHandle = intent.getLongExtra("callbackHandle", 0);
    if (sBackgroundChannel == null) {
      Log.e(
          TAG,
          "setBackgroundChannel was not called before alarms were scheduled." + " Bailing out.");
      return;
    }
    // Handle the alarm event in Dart. Note that for this plugin, we don't
    // care about the method name as we simply lookup and invoke the callback
    // provided.
    sBackgroundChannel.invokeMethod("", new Object[] {callbackHandle});
  }

  private static void scheduleAlarm(
      Context context,
      int requestCode,
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
          repeating,
          exact,
          wakeup,
          startMillis,
          intervalMillis,
          callbackHandle);
    }

    // Create an Intent for the alarm and set the desired Dart callback handle.
    Intent alarm = new Intent(context, AlarmBroadcastReceiver.class);
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

  public static void setOneShot(
      Context context,
      int requestCode,
      boolean exact,
      boolean wakeup,
      long startMillis,
      boolean rescheduleOnReboot,
      long callbackHandle) {
    final boolean repeating = false;
    scheduleAlarm(
        context,
        requestCode,
        repeating,
        exact,
        wakeup,
        startMillis,
        0,
        rescheduleOnReboot,
        callbackHandle);
  }

  public static void setPeriodic(
      Context context,
      int requestCode,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
      boolean rescheduleOnReboot,
      long callbackHandle) {
    final boolean repeating = true;
    scheduleAlarm(
        context,
        requestCode,
        repeating,
        exact,
        wakeup,
        startMillis,
        intervalMillis,
        rescheduleOnReboot,
        callbackHandle);
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
      boolean repeating,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
      long callbackHandle) {
    HashMap<String, Object> alarmSettings = new HashMap<>();
    alarmSettings.put("repeating", repeating);
    alarmSettings.put("exact", exact);
    alarmSettings.put("wakeup", wakeup);
    alarmSettings.put("startMillis", startMillis);
    alarmSettings.put("intervalMillis", intervalMillis);
    alarmSettings.put("callbackHandle", callbackHandle);
    JSONObject obj = new JSONObject(alarmSettings);
    String key = getPersistentAlarmKey(requestCode);
    SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);

    synchronized (sPersistentAlarmsLock) {
      Set<String> persistentAlarms = p.getStringSet(PERSISTENT_ALARMS_SET_KEY, null);
      if (persistentAlarms == null) {
        persistentAlarms = new HashSet<>();
      }
      if (persistentAlarms.isEmpty()) {
        RebootBroadcastReceiver.enableRescheduleOnReboot(context);
      }
      persistentAlarms.add(Integer.toString(requestCode));
      p.edit()
          .putString(key, obj.toString())
          .putStringSet(PERSISTENT_ALARMS_SET_KEY, persistentAlarms)
          .commit();
    }
  }

  private static void clearPersistentAlarm(Context context, int requestCode) {
    SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    synchronized (sPersistentAlarmsLock) {
      Set<String> persistentAlarms = p.getStringSet(PERSISTENT_ALARMS_SET_KEY, null);
      if ((persistentAlarms == null) || !persistentAlarms.contains(requestCode)) {
        return;
      }
      persistentAlarms.remove(requestCode);
      String key = getPersistentAlarmKey(requestCode);
      p.edit().remove(key).putStringSet(PERSISTENT_ALARMS_SET_KEY, persistentAlarms).commit();

      if (persistentAlarms.isEmpty()) {
        RebootBroadcastReceiver.disableRescheduleOnReboot(context);
      }
    }
  }

  public static void reschedulePersistentAlarms(Context context) {
    synchronized (sPersistentAlarmsLock) {
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
          boolean repeating = alarm.getBoolean("repeating");
          boolean exact = alarm.getBoolean("exact");
          boolean wakeup = alarm.getBoolean("wakeup");
          long startMillis = alarm.getLong("startMillis");
          long intervalMillis = alarm.getLong("intervalMillis");
          long callbackHandle = alarm.getLong("callbackHandle");
          scheduleAlarm(
              context,
              requestCode,
              repeating,
              exact,
              wakeup,
              startMillis,
              intervalMillis,
              false,
              callbackHandle);
        } catch (JSONException e) {
          Log.e(
              TAG,
              "Data for alarm request code "
                  + Integer.toString(requestCode)
                  + " is invalid: "
                  + json);
        }
      }
    }
  }
}
