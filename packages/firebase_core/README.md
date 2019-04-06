# Firebase Core for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_core.svg)](https://pub.dartlang.org/packages/firebase_core)

A Flutter plugin to use the Firebase Core API, which enables connecting to multiple Firebase apps.

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Gradle BoM setup 

If you are using a Gradle version earlier than Gradle 5 then you must add `enableFeaturePreview('IMPROVED_POM_SUPPORT')`
to the Android app's `settings.gradle` file. See example app.

The use of Gradle BoM (Bill of Materials) helps ensure that the latest versions of the FlutterFire plugins
work well together.

## Usage
To use this plugin, add `firebase_core` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

See the `example` directory for a complete sample app using Firebase Core.
