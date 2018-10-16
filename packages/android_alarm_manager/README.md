# android_alarm_manager

[![pub package](https://img.shields.io/pub/v/android_alarm_manager.svg)](https://pub.dartlang.org/packages/android_alarm_manager)

A Flutter plugin for accessing the Android AlarmManager service, and running
Dart code in the background when alarms fire.

## Getting Started

After importing this plugin to your project as usual, add the following to your
`AndroidManifest.xml`:

```xml
<service
    android:name="io.flutter.plugins.androidalarmmanager.AlarmService"
    android:exported="false"/>
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
  runApp(...);
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}
```

`printHello` will then run (roughly) every minute, even if the main app ends. However, `printHello`
will not run in the same isolate as the main application. Unlike threads, isolates do not share
memory and communication between isolates must be done via message passing (see more documentation on
isolates [here](https://api.dartlang.org/stable/2.0.0/dart-isolate/dart-isolate-library.html)).

If alarm callbacks will need access to other Flutter plugins, including the
alarm manager plugin itself, it is necessary to teach the background service how
to initialize plugins. This is done by giving the `AlarmService` a callback to call
in the application's `onCreate` method. See the example's
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

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
