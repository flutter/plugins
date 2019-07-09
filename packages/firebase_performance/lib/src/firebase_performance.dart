// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Valid HttpMethods for manual network APIs.
enum HttpMethod { Connect, Delete, Get, Head, Options, Patch, Post, Put, Trace }

/// The Firebase Performance API.
///
/// You can get an instance by calling [FirebasePerformance.instance].
class FirebasePerformance {
  FirebasePerformance._(this._handle) {
    channel.invokeMethod<bool>(
      'FirebasePerformance#instance',
      <String, dynamic>{'handle': _handle},
    );
  }

  static int _nextHandle = 0;

  final int _handle;

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  /// Singleton of [FirebasePerformance].
  static final FirebasePerformance instance =
      FirebasePerformance._(_nextHandle++);

  /// Determines whether performance monitoring is enabled or disabled.
  ///
  /// True if performance monitoring is enabled and false if performance
  /// monitoring is disabled. This is for dynamic enable/disable state. This
  /// does not reflect whether instrumentation is enabled/disabled.
  Future<bool> isPerformanceCollectionEnabled() {
    return channel.invokeMethod<bool>(
      '$FirebasePerformance#isPerformanceCollectionEnabled',
      <String, dynamic>{'handle': _handle},
    );
  }

  /// Enables or disables performance monitoring.
  ///
  /// This setting is persisted and applied on future invocations of your
  /// application. By default, performance monitoring is enabled.
  Future<void> setPerformanceCollectionEnabled(bool enable) {
    return channel.invokeMethod<void>(
      '$FirebasePerformance#setPerformanceCollectionEnabled',
      <String, dynamic>{'handle': _handle, 'enable': enable},
    );
  }

  /// Creates a [Trace] object with given [name].
  ///
  /// The [name] requires no leading or trailing whitespace, no leading
  /// underscore _ character, and max length of [Trace.maxTraceNameLength]
  /// characters.
  Trace newTrace(String name) {
    final int handle = _nextHandle++;

    FirebasePerformance.channel.invokeMethod<void>(
      '$FirebasePerformance#newTrace',
      <String, dynamic>{'handle': _handle, 'traceHandle': handle, 'name': name},
    );

    return Trace._(handle, name);
  }

  /// Creates [HttpMetric] for collecting performance for one request/response.
  HttpMetric newHttpMetric(String url, HttpMethod httpMethod) {
    final int handle = _nextHandle++;

    FirebasePerformance.channel.invokeMethod<void>(
      '$FirebasePerformance#newHttpMetric',
      <String, dynamic>{
        'handle': _handle,
        'httpMetricHandle': handle,
        'url': url,
        'httpMethod': httpMethod.toString(),
      },
    );

    return HttpMetric._(handle, url, httpMethod);
  }

  /// Creates a [Trace] object with given [name] and starts the trace.
  ///
  /// The [name] requires no leading or trailing whitespace, no leading
  /// underscore _ character, max length of [Trace.maxTraceNameLength]
  /// characters.
  static Future<Trace> startTrace(String name) async {
    final Trace trace = instance.newTrace(name);
    await trace.start();
    return trace;
  }
}
