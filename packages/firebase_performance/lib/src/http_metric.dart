// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Metric used to collect data for network requests/responses.
///
/// It is possible to have more than one [HttpMetric] running at a time.
/// Attributes can also be added to help measure performance related events. A
/// [HttpMetric] also measures the time between calling start() and stop().
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
class HttpMetric extends PerformanceAttributes {
  HttpMetric._(this.channel);

  @override
  bool _hasStarted = false;

  @override
  bool _hasStopped = false;

  int _httpResponseCode;
  int _requestPayloadSize;
  String _responseContentType;
  int _responsePayloadSize;

  @visibleForTesting
  @override
  final MethodChannel channel;

  /// HttpResponse code of the request.
  int get httpResponseCode => _httpResponseCode;

  /// Size of the request payload.
  int get requestPayloadSize => _requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String get responseContentType => _responseContentType;

  /// Size of the response payload.
  int get responsePayloadSize => _responsePayloadSize;

  /// HttpResponse code of the request.
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set httpResponseCode(int httpResponseCode) {
    if (_hasStopped) return;

    _httpResponseCode = httpResponseCode;
    channel.invokeMethod<void>(
      '$HttpMetric#httpResponseCode',
      httpResponseCode,
    );
  }

  /// Size of the request payload.
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set requestPayloadSize(int requestPayloadSize) {
    if (_hasStopped) return;

    _requestPayloadSize = requestPayloadSize;
    channel.invokeMethod<void>(
      '$HttpMetric#requestPayloadSize',
      requestPayloadSize,
    );
  }

  /// Content type of the response such as text/html, application/json, etc...
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set responseContentType(String responseContentType) {
    if (_hasStopped) return;

    _responseContentType = responseContentType;
    channel.invokeMethod<void>(
      '$HttpMetric#responseContentType',
      responseContentType,
    );
  }

  /// Size of the response payload.
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set responsePayloadSize(int responsePayloadSize) {
    if (_hasStopped) return;

    _responsePayloadSize = responsePayloadSize;
    channel.invokeMethod<void>(
      '$HttpMetric#responsePayloadSize',
      responsePayloadSize,
    );
  }

  /// Starts this [HttpMetric].
  ///
  /// Can only be called once.
  ///
  /// Using `await` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    if (_hasStopped) return Future<void>.value(null);

    _hasStarted = true;
    return channel.invokeMethod<void>('$HttpMetric#start');
  }

  /// Stops this [HttpMetric].
  ///
  /// Can only be called once and only after start(), Data collected is
  /// automatically sent to the associate Firebase console after stop() is
  /// called. You can confirm that Performance Monitoring results appear in the
  /// Firebase console. Results should appear within 12 hours.
  ///
  /// Not necessary to use `await` with this method.
  Future<void> stop() {
    if (_hasStopped) return Future<void>.value(null);

    _hasStopped = true;
    return channel.invokeMethod<void>('$HttpMetric#stop');
  }
}
