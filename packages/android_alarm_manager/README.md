# android_alarm_manager

---

## Deprecation Notice

This plugin has been replaced by the [Flutter Community Plus
Plugins](https://plus.fluttercommunity.dev/) version,
[`android_alarm_manager_plus`](https://pub.dev/packages/android_alarm_manager_plus).
No further updates are planned to this plugin, and we encourage all users to
migrate to the Plus version.

Critical fixes (e.g., for any security incidents) will be provided through the
end of 2021, at which point this package will be marked as discontinued.

---

[![pub package](https://img.shields.io/pub/v/android_alarm_manager.svg)](https://pub.dev/packages/android_alarm_manager)

A Flutter plugin for accessing the Android AlarmManager service, and running
Dart code in the background when alarms fire.

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
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
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

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).

For help on editing plugin code, view the [documentation](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin).
