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
  HttpMetric._(this._handle, this._url, this._httpMethod);

  final int _handle;
  final String _url;
  final HttpMethod _httpMethod;

  bool _hasStarted = false;
  bool _hasStopped = false;

  /// HttpResponse code of the request.
  int httpResponseCode;

  /// Size of the request payload.
  int requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String responseContentType;

  /// Size of the response payload.
  int responsePayloadSize;

  /// Starts this httpmetric.
  ///
  /// Can only be called once, otherwise assertion error is thrown.
  ///
  /// Using ```await``` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    assert(!_hasStarted);

    _hasStarted = true;
    return FirebasePerformance.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('HttpMetric#start', <String, dynamic>{
      'handle': _handle,
      'url': _url,
      'httpMethod': _httpMethod.index,
    });
  }

  /// Stops this httpMetric.
  ///
  /// Can only be called once and only after start(), otherwise assertion error
  /// is thrown. Data collected is automatically sent to the associated
  /// Firebase console after stop() is called.
  ///
  /// Not necessary to use ```await``` with this method.
  Future<void> stop() {
    assert(!_hasStopped);
    assert(_hasStarted);

    final Map<String, dynamic> data = <String, dynamic>{
      'handle': _handle,
      'httpResponseCode': httpResponseCode,
      'requestPayloadSize': requestPayloadSize,
      'responseContentType': responseContentType,
      'responsePayloadSize': responsePayloadSize,
      'attributes': _attributes,
    };

    _hasStopped = true;
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return FirebasePerformance.channel.invokeMethod('HttpMetric#stop', data);
  }

  /// Sets a String [value] for the specified [attribute].
  ///
  /// If the httpmetric has been stopped, this method throws an assertion
  /// error.
  ///
  /// See [PerformanceAttributes.putAttribute].
  @override
  void putAttribute(String attribute, String value) {
    assert(!_hasStopped);
    super.putAttribute(attribute, value);
  }

  /// Removes an already added [attribute].
  ///
  /// If the httpmetric has been stopped, this method throws an assertion
  /// error.
  ///
  /// See [PerformanceAttributes.removeAttribute].
  @override
  void removeAttribute(String attribute) {
    assert(!_hasStopped);
    super.removeAttribute(attribute);
  }
}
