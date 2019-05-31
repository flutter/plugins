// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanager;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
<<<<<<< HEAD
import android.os.IBinder;
=======
import android.content.SharedPreferences;
import android.os.Handler;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
import android.util.Log;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;
import java.util.concurrent.atomic.AtomicBoolean;

<<<<<<< HEAD
public class AlarmService extends Service {
  public static final String TAG = "AlarmService";
  private static AtomicBoolean sStarted = new AtomicBoolean(false);
=======
public class AlarmService extends JobIntentService {
  // TODO(mattcarroll): tags should be private. Make private if no public usage.
  public static final String TAG = "AlarmService";
  private static final String CALLBACK_HANDLE_KEY = "callback_handle";
  private static final String PERSISTENT_ALARMS_SET_KEY = "persistent_alarm_ids";
  private static final String SHARED_PREFERENCES_KEY = "io.flutter.android_alarm_manager_plugin";
  private static final int JOB_ID = 1984; // Random job ID.
  private static final Object sPersistentAlarmsLock = new Object();

  // TODO(mattcarroll): make sIsIsolateRunning per-instance, not static.
  private static AtomicBoolean sIsIsolateRunning = new AtomicBoolean(false);

  // TODO(mattcarroll): make sAlarmQueue per-instance, not static.
  private static List<Intent> sAlarmQueue = Collections.synchronizedList(new LinkedList<Intent>());

  /** Background Dart execution context. */
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  private static FlutterNativeView sBackgroundFlutterView;

  /**
   * The {@link MethodChannel} that connects the Android side of this plugin with the background
   * Dart isolate that was created by this plugin.
   */
  private static MethodChannel sBackgroundChannel;

<<<<<<< HEAD
  public static void onInitialized() {
    sStarted.set(true);
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
=======
  private static PluginRegistrantCallback sPluginRegistrantCallback;

  // Schedule the alarm to be handled by the AlarmService.
  public static void enqueueAlarmProcessing(Context context, Intent alarmContext) {
    enqueueWork(context, AlarmService.class, JOB_ID, alarmContext);
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterNativeView}.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method represented by {@code callbackHandle}.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given {@code callbackHandle} must correspond to a registered Dart callback. If the
   *       handle does not resolve to a Dart callback then this method does nothing.
   *   <li>A static {@link #sPluginRegistrantCallback} must exist, otherwise a {@link
   *       PluginRegistrantException} will be thrown.
   * </ul>
   */
  public static void startBackgroundIsolate(Context context, long callbackHandle) {
    // TODO(mattcarroll): re-arrange order of operations. The order is strange - there are 3
    // conditions that must be met for this method to do anything but they're split up for no
    // apparent reason. Do the qualification checks first, then execute the method's logic.
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
    FlutterMain.ensureInitializationComplete(context, null);
    String mAppBundlePath = FlutterMain.findAppBundlePath(context);
    FlutterCallbackInformation flutterCallback =
        FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
    if (flutterCallback == null) {
      Log.e(TAG, "Fatal: failed to find callback");
      return;
    }

    // Note that we're passing `true` as the second argument to our
    // FlutterNativeView constructor. This specifies the FlutterNativeView
    // as a background view and does not create a drawing surface.
    sBackgroundFlutterView = new FlutterNativeView(context, true);
<<<<<<< HEAD
    if (mAppBundlePath != null && !sStarted.get()) {
=======
    if (mAppBundlePath != null && !sIsIsolateRunning.get()) {
      if (sPluginRegistrantCallback == null) {
        throw new PluginRegistrantException();
      }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      Log.i(TAG, "Starting AlarmService...");
      FlutterRunArguments args = new FlutterRunArguments();
      args.bundlePath = mAppBundlePath;
      args.entrypoint = flutterCallback.callbackName;
      args.libraryPath = flutterCallback.callbackLibraryPath;
      sBackgroundFlutterView.runFromBundle(args);
      sPluginRegistrantCallback.registerWith(sBackgroundFlutterView.getPluginRegistry());
    }
  }

  /**
   * Called once the Dart isolate ({@code sBackgroundFlutterView}) has finished initializing.
   *
   * <p>Invoked by {@link AndroidAlarmManagerPlugin} when it receives the {@code
   * AlarmService.initialized} message. Processes all alarm events that came in while the isolate
   * was starting.
   */
  // TODO(mattcarroll): consider making this method package private
  public static void onInitialized() {
    Log.i(TAG, "AlarmService started!");
    sIsIsolateRunning.set(true);
    synchronized (sAlarmQueue) {
      // Handle all the alarm events received before the Dart isolate was
      // initialized, then clear the queue.
      Iterator<Intent> i = sAlarmQueue.iterator();
      while (i.hasNext()) {
        executeDartCallbackInBackgroundIsolate(i.next());
      }
      sAlarmQueue.clear();
    }
  }

  /**
   * Sets the {@link MethodChannel} that is used to communicate with Dart callbacks that are invoked
   * in the background by the android_alarm_manager plugin.
   */
  public static void setBackgroundChannel(MethodChannel channel) {
    sBackgroundChannel = channel;
  }

<<<<<<< HEAD
  public static void setOneShot(
      Context context,
      int requestCode,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long callbackHandle) {
    final boolean repeating = false;
    scheduleAlarm(context, requestCode, repeating, exact, wakeup, startMillis, 0, callbackHandle);
  }

  public static void setPeriodic(
      Context context,
      int requestCode,
      boolean exact,
      boolean wakeup,
      long startMillis,
      long intervalMillis,
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
        callbackHandle);
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
=======
  /**
   * Sets the Dart callback handle for the Dart method that is responsible for initializing the
   * background Dart isolate, preparing it to receive Dart callback tasks requests.
   */
  public static void setCallbackDispatcher(Context context, long callbackHandle) {
    SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    prefs.edit().putLong(CALLBACK_HANDLE_KEY, callbackHandle).apply();
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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

<<<<<<< HEAD
  @Override
  public void onCreate() {
    super.onCreate();
    Context context = getApplicationContext();
    FlutterMain.ensureInitializationComplete(context, null);
    mAppBundlePath = FlutterMain.findAppBundlePath(context);
  }

  // This is where we handle alarm events before sending them to our callback
  // dispatcher in Dart.
  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    if (!sStarted.get()) {
      Log.i(TAG, "AlarmService has not yet started.");
      // TODO(bkonyi): queue up alarm events.
      return START_NOT_STICKY;
    }
=======
  /**
   * Executes the desired Dart callback in a background Dart isolate.
   *
   * <p>The given {@code intent} should contain a {@code long} extra called "callbackHandle", which
   * corresponds to a callback registered with the Dart VM.
   */
  private static void executeDartCallbackInBackgroundIsolate(Intent intent) {
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
    // Grab the handle for the callback associated with this alarm. Pay close
    // attention to the type of the callback handle as storing this value in a
    // variable of the wrong size will cause the callback lookup to fail.
    long callbackHandle = intent.getLongExtra("callbackHandle", 0);
    if (sBackgroundChannel == null) {
      Log.e(
          TAG,
          "setBackgroundChannel was not called before alarms were scheduled." + " Bailing out.");
      return START_NOT_STICKY;
    }
    // Handle the alarm event in Dart. Note that for this plugin, we don't
    // care about the method name as we simply lookup and invoke the callback
    // provided.
    // TODO(mattcarroll): consider giving a method name anyway for the purpose of developer discoverability
    //                    when reading the source code. Especially on the Dart side.
    sBackgroundChannel.invokeMethod("", new Object[] {callbackHandle});
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
      long callbackHandle) {
    // Create an Intent for the alarm and set the desired Dart callback handle.
    Intent alarm = new Intent(context, AlarmService.class);
    alarm.putExtra("callbackHandle", callbackHandle);
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
<<<<<<< HEAD
=======

  public static void setOneShot(Context context, AndroidAlarmManagerPlugin.OneShotRequest request) {
    final boolean repeating = false;
    scheduleAlarm(
        context,
        request.requestCode,
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
    scheduleAlarm(
        context,
        request.requestCode,
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
    SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);

    synchronized (sPersistentAlarmsLock) {
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

  private String mAppBundlePath;

  @Override
  public void onCreate() {
    super.onCreate();

    Context context = getApplicationContext();
    FlutterMain.ensureInitializationComplete(context, null);
    mAppBundlePath = FlutterMain.findAppBundlePath(context);

    if (!sIsIsolateRunning.get()) {
      SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
      long callbackHandle = p.getLong(CALLBACK_HANDLE_KEY, 0);
      startBackgroundIsolate(context, callbackHandle);
    }
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
   * {@code intent} is added to the {@link #sAlarmQueue} to invoked later, after all pre-existing
   * callbacks have been executed.
   */
  @Override
  protected void onHandleWork(final Intent intent) {
    // If we're in the middle of processing queued alarms, add the incoming
    // intent to the queue and return.
    synchronized (sAlarmQueue) {
      if (!sIsIsolateRunning.get()) {
        Log.i(TAG, "AlarmService has not yet started.");
        sAlarmQueue.add(intent);
        return;
      }
    }

    // There were no pre-existing callback requests. Execute the callback
    // specified by the incoming intent.
    new Handler(getMainLooper())
        .post(
            new Runnable() {
              @Override
              public void run() {
                executeDartCallbackInBackgroundIsolate(intent);
              }
            });
  }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
}
