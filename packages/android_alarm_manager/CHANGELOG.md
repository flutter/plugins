## 0.4.5+12

* Update package:e2e reference to use the local version in the flutter/plugins
  repository.

## 0.4.5+11

* Update lower bound of dart dependency to 2.1.0.

## 0.4.5+10

* Declare API stability and compatibility with `1.0.0` (more details at: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.4.5+9

* Fix CocoaPods podspec lint warnings.

## 0.4.5+8

* Remove `MainActivity` references in android example app and tests.

## 0.4.5+7

* Update minimum Flutter version to 1.12.13+hotfix.5
* Clean up various Android workarounds no longer needed after framework v1.12.
* Complete v2 embedding support.

## 0.4.5+6

* Replace deprecated `getFlutterEngine` call on Android.

## 0.4.5+5

* Added an Espresso test.

## 0.4.5+4

* Make the pedantic dev_dependency explicit.

## 0.4.5+3

* Fixed issue where callback lookup would fail while running in the background.

## 0.4.5+2

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.4.5+1

* Loosen Flutter version restriction to 1.9.1. **NOTE: plugin registration
  for the background isolate will not work correctly for applications using the
  V2 Flutter Android embedding for Flutter versions lower than 1.12.**

## 0.4.5

* Add support for Flutter Android embedding V2

## 0.4.4+3

* Add unit tests and DartDocs.

## 0.4.4+2

* Remove AndroidX warning.

## 0.4.4+1

* Update and migrate iOS example project.
* Define clang module for iOS.

## 0.4.4

* Add `id` to `callback` if it is of type `Function(int)`

## 0.4.3

* Added `oneShotAt` method to run `callback` at a given DateTime `time`.

## 0.4.2

* Added support for setting alarms which work when the phone is in doze mode.

## 0.4.1+8

* Remove dependency on google-services in the Android example.

## 0.4.1+7

* Fix possible crash on Android devices with APIs below 19.

## 0.4.1+6

* Bump the minimum Flutter version to 1.2.0.
* Add template type parameter to `invokeMethod` calls.

## 0.4.1+5

* Update AlarmService to throw a `PluginRegistrantException` if
  `AlarmService.setPluginRegistrant` has not been called to set a
  PluginRegistrantCallback. This improves the error message seen when the
  `AlarmService.setPluginRegistrant` call is omitted.

## 0.4.1+4

* Updated example to remove dependency on Firebase.

## 0.4.1+3

* Update README.md to include instructions for setting the WAKE_LOCK permission.
* Updated example application to use the WAKE_LOCK permission.

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
