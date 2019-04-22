// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Metric used to collect data for network requests/responses.
///
/// It is possible to have more than one httpmetric running at a time.
/// Attributes can also be added to help measure performance related events. A
/// httpmetric also measures the time between calling start() and stop().
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
class HttpMetric extends PerformanceAttributes {
  HttpMetric._(this._channel);

  final MethodChannel _channel;

  /// HttpResponse code of the request.
  int httpResponseCode;

  /// Size of the request payload.
  int requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String responseContentType;

  /// Size of the response payload.
  int responsePayloadSize;

  @override
  MethodChannel get _methodChannel => null;

  /// Starts this [HttpMetric] asynchronously.
  ///
  /// Using ```await``` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    return _channel.invokeMethod<void>('$Trace#start');
  }

  /// Stops this httpMetric.
  ///
  /// Can only be called once and only after start(), Data collected is
  /// automatically sent to the associate Firebase console after stop() is
  /// called. You can confirm that Performance Monitoring results appear in the
  /// Firebase console. Results should appear within 12 hours.
  ///
  /// Not necessary to use ```await``` with this method.
  Future<void> stop() {
    final Map<String, dynamic> data = <String, dynamic>{
      'httpResponseCode': httpResponseCode,
      'requestPayloadSize': requestPayloadSize,
      'responseContentType': responseContentType,
      'responsePayloadSize': responsePayloadSize,
    };

    return _channel.invokeMethod<void>('$Trace#stop', data);
  }
}
