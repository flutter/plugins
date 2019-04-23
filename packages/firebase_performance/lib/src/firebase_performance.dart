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

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  /// Singleton of [FirebasePerformance].
  static final FirebasePerformance instance = FirebasePerformance._();

  static int _channelCount = 0;

  /// Determines whether performance monitoring is enabled or disabled.
  ///
  /// True if performance monitoring is enabled and false if performance
  /// monitoring is disabled. This is for dynamic enable/disable state. This
  /// does not reflect whether instrumentation is enabled/disabled.
  Future<bool> isPerformanceCollectionEnabled() {
    return channel.invokeMethod<bool>(
      'FirebasePerformance#isPerformanceCollectionEnabled',
    );
  }

  /// Enables or disables performance monitoring.
  ///
  /// This setting is persisted and applied on future invocations of your
  /// application. By default, performance monitoring is enabled.
  Future<void> setPerformanceCollectionEnabled(bool enable) async {
    return channel.invokeMethod<void>(
      'FirebasePerformance#setPerformanceCollectionEnabled',
      enable,
    );
  }

  /// Creates a [Trace] object with given [name].
  ///
  /// The [name] requires no leading or trailing whitespace, no leading
  /// underscore _ character, and max length of [Trace.maxTraceNameLength]
  /// characters.
  Trace newTrace(String name) {
    final String channelName =
        '${FirebasePerformance.channel.name}/$Trace/${_channelCount++}';

    FirebasePerformance.channel.invokeMethod<void>(
      '$FirebasePerformance#newTrace',
      <String, dynamic>{'channelName': channelName, 'traceName': name},
    );

    final MethodChannel channel = MethodChannel(channelName);
    return Trace._(channel);
  }

  /// Creates [HttpMetric] for collecting performance for one request/response.
  HttpMetric newHttpMetric(String url, HttpMethod httpMethod) {
    final String channelName =
        '${FirebasePerformance.channel.name}/$HttpMetric/${_channelCount++}';

    FirebasePerformance.channel.invokeMethod<void>(
      '$FirebasePerformance#newHttpMetric',
      <String, dynamic>{
        'channelName': channelName,
        'url': url,
        'httpMethod': httpMethod.toString(),
      },
    );

    final MethodChannel channel = MethodChannel(channelName);
    return HttpMetric._(channel);
  }
}
