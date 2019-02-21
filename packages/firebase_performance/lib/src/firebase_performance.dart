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
  FirebasePerformance._();

  static int _traceCount = 0;
  static int _httpMetricCount = 0;

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  /// Singleton of [FirebasePerformance].
  static final FirebasePerformance instance = FirebasePerformance._();

  /// Determines whether performance monitoring is enabled or disabled.
  ///
  /// True if performance monitoring is enabled and false if performance
  /// monitoring is disabled. This is for dynamic enable/disable state. This
  /// does not reflect whether instrumentation is enabled/disabled.
  Future<bool> isPerformanceCollectionEnabled() async {
    final bool isEnabled = await channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('FirebasePerformance#isPerformanceCollectionEnabled');
    return isEnabled;
  }

  /// Enables or disables performance monitoring.
  ///
  /// This setting is persisted and applied on future invocations of your
  /// application. By default, performance monitoring is enabled.
  Future<void> setPerformanceCollectionEnabled(bool enable) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod(
        'FirebasePerformance#setPerformanceCollectionEnabled', enable);
  }

  /// Creates a [Trace] object with given [name].
  ///
  /// The [name] requires no leading or trailing whitespace, no leading
  /// underscore _ character, max length of [Trace.maxTraceNameLength]
  /// characters.
  Trace newTrace(String name) {
    return Trace._(_traceCount++, name);
  }

  /// Creates [HttpMetric] for collecting performance for one request/response.
  HttpMetric newHttpMetric(String url, HttpMethod httpMethod) {
    return HttpMetric._(_httpMetricCount++, url, httpMethod);
  }

  /// Creates a [Trace] object with given [name] and start the trace.
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
