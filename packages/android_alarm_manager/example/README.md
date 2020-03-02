# android_alarm_manager_example

Demonstrates how to use the android_alarm_manager plugin.

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).
packages/android_alarm_manager/README.md

## Espresso test

To run the Espresso test, the following manual steps are required.

* Uncomment the espresso dependency in example/pubspec.yaml
* mv example/android/app/src/androidTest/java/io/plugins/androidalarmmanager/MainActivityTest.java
  android/app/src/androidTest/java/io/plugins/androidalarmmanager/MainActivityTest.java.disabled
* mv example/android/app/src/androidTest/java/io/plugins/androidalarmmanager/BackgroundExecutionTest.java.disabled
  android/app/src/androidTest/java/io/plugins/androidalarmmanager/BackgroundExecutionTest.java
* ./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../test_driver/alarm_maanger.dart

These will be no longer necessary once https://github.com/flutter/flutter/issues/51781 is resolved.
