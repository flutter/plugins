# Firebase Analytics for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_analytics.svg)](https://pub.dartlang.org/packages/firebase_analytics)

A Flutter plugin to use the [Firebase Analytics API](https://firebase.google.com/docs/analytics/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage
To use this plugin, add `firebase_analytics` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Track PageRoute Transitions

To track `PageRoute` transitions, add a `FirebaseAnalyticsObserver` to the list of `NavigatorObservers` on your
`Navigator`, e.g. if you're using a `MaterialApp`:

```dart

FirebaseAnalytics analytics = new FirebaseAnalytics();

MaterialApp(
  home: new MyAppHome(),
  navigatorObservers: [
    new FirebaseAnalyticsPageRouteObserver(analytics: analytics),
  ],
);
```

You can also track transitions within your `PageRoute` (e.g. when the user switches from one tab to another) by
implementing `RouteAware` and subscribing it to `FirebaseAnalyticsObserver`. See `examples/lib/tabs_page.dart`
for an example of how to wire that up.

## Getting Started

See the `example` directory for a complete sample app using Firebase Analytics.
