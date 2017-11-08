# android_alarm_manager

A Flutter plugin for accessing the Android AlarmManager service, and running
Dart code in the background when alarms fire.

## Getting Started

After importing this plugin to your project as usual, add the following to your
`AndroidManifest.xml`:

```xml
<service
    android:name="io.flutter.androidalarmmanager.AlarmService"
    android:exported="false"/>
```

Then in Dart code add:

```dart
import 'package:android_alarm_manager/android_alarm_manager.dart';

void printHello() {
  final DateTime now = new DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
}

main() async {
  final int helloAlarmID = 0;
  runApp(...);
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}
```

`printHello` will then run (roughly) every minute, even if the main app ends. If
possible it will reuse the same Dart Isolate from the application's main
activity. Additionally, if you would like a new main activity of your application
to reuse the Isolate from an existing background service created by this plugin,
add the following override to your app's `MainActivity` class:

```java
@Override
public FlutterNativeView createFlutterNativeView() {
  return AlarmService.getSharedFlutterView();
}
```

See the [example's](https://github.com/flutter/plugins/tree/master/packages/android_alarm_manager/example)
[MainActivity](https://github.com/flutter/plugins/blob/master/packages/android_alarm_manager/example/android/app/src/main/java/io/flutter/androidalarmmanagerexample/MainActivity.java)
to see an example.

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
