# android_alarm_manager

[![pub package](https://img.shields.io/pub/v/android_alarm_manager.svg)](https://pub.dartlang.org/packages/android_alarm_manager)

A Flutter plugin for accessing the Android AlarmManager service, and running
Dart code in the background when alarms fire.

**Please set your constraint to `android_alarm_manager: '>=0.4.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.4.y+z`.
Please use `android_alarm_manager: '>=0.4.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Getting Started

After importing this plugin to your project as usual, add the following to your
`AndroidManifest.xml` within the `<manifest></manifest>` tags:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

Next, within the `<application></application>` tags, add:

```xml
<service
    android:name="io.flutter.plugins.androidalarmmanager.AlarmService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:exported="false"/>
<receiver
    android:name="io.flutter.plugins.androidalarmmanager.AlarmBroadcastReceiver"
    android:exported="false"/>
<receiver
    android:name="io.flutter.plugins.androidalarmmanager.RebootBroadcastReceiver"
    android:enabled="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"></action>
    </intent-filter>
</receiver>

```

Then in Dart code add:

```dart
import 'package:android_alarm_manager/android_alarm_manager.dart';

void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
}

main() async {
  final int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();
  runApp(...);
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}
```

`printHello` will then run (roughly) every minute, even if the main app ends. However, `printHello`
will not run in the same isolate as the main application. Unlike threads, isolates do not share
memory and communication between isolates must be done via message passing (see more documentation on
isolates [here](https://api.dart.dev/stable/2.0.0/dart-isolate/dart-isolate-library.html)).


## Using other plugins in alarm callbacks

If alarm callbacks will need access to other Flutter plugins, including the
alarm manager plugin itself, it may be necessary to inform the background service how
to initialize plugins depending on which Flutter Android embedding the application is
using.

### Flutter Android Embedding V1

For the Flutter Android Embedding V1, the background service must be provided a
callback to register plugins with the background isolate. This is done by giving
the `AlarmService` a callback to call the application's `onCreate` method. See the example's
[Application overrides](https://github.com/flutter/plugins/blob/master/packages/android_alarm_manager/example/android/app/src/main/java/io/flutter/plugins/androidalarmmanagerexample/Application.java).

In particular, its `Application` class is as follows:

```java
public class Application extends FlutterApplication implements PluginRegistrantCallback {
  @Override
  public void onCreate() {
    super.onCreate();
    AlarmService.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry) {
    GeneratedPluginRegistrant.registerWith(registry);
  }
}
```

Which must be reflected in the application's `AndroidManifest.xml`. E.g.:

```xml
    <application
        android:name=".Application"
        ...
```

**Note:** Not calling `AlarmService.setPluginRegistrant` will result in an exception being
thrown when an alarm eventually fires.

### Flutter Android Embedding V2 (Flutter Version >= 1.12)

For the Flutter Android Embedding V2, plugins are registered with the background
isolate via reflection so `AlarmService.setPluginRegistrant` does not need to be
called.

**NOTE: this plugin is not completely compatible with the V2 embedding on
Flutter versions < 1.12 as the background isolate will not automatically
register plugins. This can be resolved by running `flutter upgrade` to upgrade
to the latest Flutter version.**

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
