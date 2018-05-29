// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Metric used to collect data for network requests/responses.
class HttpMetric extends PerformanceAttributable {
  HttpMetric._(this._handle, this._url, this._httpMethod);

  final int _handle;
  final String _url;
  final HttpMethod _httpMethod;

  bool _hasStarted = false;
  bool _hasStopped = false;

  /// HttpResponse code of the request
  int httpResponseCode;

  /// Size of the request payload
  int requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String responseContentType;

  /// Size of the response payload
  int responsePayloadSize;

  /// Starts this httpMetric.
  ///
  /// Using ```await``` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    assert(!_hasStarted);

    _hasStarted = true;
    return FirebasePerformance.channel
        .invokeMethod('HttpMetric#start', <String, dynamic>{
      'handle': _handle,
      'url': _url,
      'httpMethod': _httpMethod.index,
    });
  }

  /// Stops this httpMetric.
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
    return FirebasePerformance.channel.invokeMethod('HttpMetric#stop', data);
  }

  /// Sets a String [value] for the specified [attribute].
  ///
  /// Updates the value of the attribute if the attribute already exists. If the
  /// trace has been stopped, this method returns without adding the attribute.
  /// The maximum number of attributes that can be added to a Trace are
  /// [PerformanceAttributable.maxTraceCustomAttributes].
  ///
  /// Name of the attribute has max length of
  /// [PerformanceAttributable.maxAttributeKeyLength] characters. Value of the
  /// attribute has max length of
  /// [PerformanceAttributable.maxAttributeValueLength] characters.
  @override
  void putAttribute(String attribute, String value) {
    assert(!_hasStopped);
    super.putAttribute(attribute, value);
  }

  /// Removes an already added [attribute].
  ///
  /// If the trace has been stopped, this method throws an assertion
  /// error.
  @override
  void removeAttribute(String attribute) {
    assert(!_hasStopped);
    super.removeAttribute(attribute);
  }
}
