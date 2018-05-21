# Google Performance Monitoring for Firebase

[![pub package](https://img.shields.io/pub/v/firebase_performance.svg)](https://pub.dartlang.org/packages/firebase_performance)

A Flutter plugin to use the [Google Performance Monitoring for Firebase API](https://firebase.google.com/docs/perf-mon/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage
To use this plugin, add `firebase_performance` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure firebase performance monitoring for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

## Define a Custom Trace

A custom trace is a report of performance data associated with some of the code in your app. To learn more about custom traces, see the [Performance Monitoring overview](https://firebase.google.com/docs/perf-mon/#how_does_it_work).

```dart

Trace myTrace = FirebasePerformance.instance.newTrace("test_trace");
myTrace.start();

Item item = cache.fetch("item");
if (item != null) {
  myTrace.incrementCounter("item_cache_hit");
} else {
  myTrace.incrementCounter("item_cache_miss");
}

myTrace.stop();

```

## Getting Started

See the `example` directory for a complete sample app using Google Performance Monitoring for Firebase.