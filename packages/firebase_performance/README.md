# Google Performance Monitoring for Firebase

[![pub package](https://img.shields.io/pub/v/firebase_performance.svg)](https://pub.dartlang.org/packages/firebase_performance)

A Flutter plugin to use the [Google Performance Monitoring for Firebase API](https://firebase.google.com/docs/perf-mon/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage

To use this plugin, add `firebase_performance` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure firebase performance monitoring for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

You can confirm that Performance Monitoring results appear in the [Firebase console.](https://console.firebase.google.com/) Results should appear within 12 hours.

## Define a Custom Trace

A custom trace is a report of performance data associated with some of the code in your app. To learn more about custom traces, see the [Performance Monitoring overview](https://firebase.google.com/docs/perf-mon/#how_does_it_work).

```dart
final Trace myTrace = FirebasePerformance.instance.newTrace("test_trace");
myTrace.start();

final Item item = cache.fetch("item");
if (item != null) {
  myTrace.incrementMetric("item_cache_hit", 1);
} else {
  myTrace.incrementMetric("item_cache_miss", 1);
}

myTrace.stop();
```

## Add monitoring for specific network requests

Performance Monitoring collects network requests automatically. Although this includes most network requests for your app, some might not be reported. To include specific network requests in Performance Monitoring, add the following code to your app:

```dart
class _MetricHttpClient extends BaseClient {
  _MetricHttpClient(this._inner);

  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(request.url.toString(), HttpMethod.Get);

    await metric.start();

    StreamedResponse response;
    try {
      response = await _inner.send(request);
      metric
        ..responsePayloadSize = response.contentLength
        ..responseContentType = response.headers['Content-Type']
        ..requestPayloadSize = request.contentLength
        ..httpResponseCode = response.statusCode;
    } finally {
      await metric.stop();
    }

    return response;
  }
}

class _MyAppState extends State<MyApp> {
.
.
.
  Future<void> testHttpMetric() async {
    final _MetricHttpClient metricHttpClient = _MetricHttpClient(Client());

    final Request request =
        Request("SEND", Uri.parse("https://www.google.com"));

    metricHttpClient.send(request);
  }
.
.
.
}
```

## Getting Started

See the `example` directory for a complete sample app using Google Performance Monitoring for Firebase.
