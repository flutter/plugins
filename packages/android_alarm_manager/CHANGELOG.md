## 0.4.1+2

* Include a missing API dependency.

## 0.4.1+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.4.1
* Added support for setting alarms which persist across reboots.
  * Both `AndroidAlarmManager.oneShot` and `AndroidAlarmManager.periodic` have
    an optional `rescheduleOnReboot` parameter which specifies whether the new
    alarm should be rescheduled to run after a reboot (default: false). If set
    to false, the alarm will not survive a device reboot.
  * Requires AndroidManifest.xml to be updated to include the following
    entries:

    ```xml
    <!--Within the application tag body-->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <!--Within the manifest tag body-->
    <receiver
        android:name="io.flutter.plugins.androidalarmmanager.RebootBroadcastReceiver"
        android:enabled="false">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"></action>
        </intent-filter>
    </receiver>

    ```

## 0.4.0

* **Breaking change**. Migrated the underlying AlarmService to utilize a
  BroadcastReceiver with a JobIntentService instead of a Service to handle
  processing of alarms. This requires AndroidManifest.xml to be updated to
  include the following entries:

  ```xml
        <service
            android:name="io.flutter.plugins.androidalarmmanager.AlarmService"
            android:permission="android.permission.BIND_JOB_SERVICE"
            android:exported="false"/>
        <receiver
            android:name="io.flutter.plugins.androidalarmmanager.AlarmBroadcastReceiver"
            android:exported="false"/>
  ```

* Fixed issue where background service was not starting due to background
  execution restrictions on Android 8+ (see [issue
  #26846](https://github.com/flutter/flutter/issues/26846)).
* Fixed issue where alarm events were ignored when the background isolate was
  still initializing. Alarm events are now queued if the background isolate has
  not completed initializing and are processed once initialization is complete.

## 0.3.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.2.3
* Move firebase_auth from a dependency to a dev_dependency.

## 0.2.2
* Update dependencies for example to point to published versions of firebase_auth.

## 0.2.1
* Update dependencies for example to point to published versions of firebase_auth
  and google_sign_in.
* Add missing dependency on firebase_auth.

## 0.2.0

* **Breaking change**. A new isolate is always spawned for the background service
  instead of trying to share an existing isolate owned by the application.
* **Breaking change**. Removed `AlarmService.getSharedFlutterView`.

## 0.1.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.1.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.0.5

* Simplified and upgraded Android project template to Android SDK 27.
* Moved Android package to io.flutter.plugins.

## 0.0.4

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.0.3

* Adds use of a Firebase plugin to the example. The example also now
  demonstrates overriding the Application's onCreate method so that the
  AlarmService can initialize plugin connections.

## 0.0.2

* Add FLT prefix to iOS types.

## 0.0.1

* Initial release.
