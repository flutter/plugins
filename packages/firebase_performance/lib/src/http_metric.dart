// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

class HttpMetric {
  HttpMetric._(this._handle, this._url, this._httpMethod);

  final int _handle;
  final String _url;
  final HttpMethod _httpMethod;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final HashMap<String, String> _attributes = new HashMap<String, String>();

  /// HttpResponse code of the request
  int httpResponseCode;

  /// Size of the request payload
  int requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String responseContentType;

  /// Size of the response payload
  int responsePayloadSize;

  /// All the attributes added.
  Map<String, String> get attributes =>
      Map<String, String>.unmodifiable(_attributes);

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
  /// [HttpMetric] has been stopped, this method returns without adding the
  /// attribute. The maximum number of attributes that can be added to a
  /// [HttpMetric] are [Trace.maxTraceCustomAttributes].
  ///
  /// Name of the attribute has max length of [Trace.maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [Trace.maxAttributeValueLength] characters.
  void putAttribute(String attribute, String value) {
    assert(!_hasStopped);
    assert(attribute != null);
    assert(!attribute.startsWith(new RegExp(r'[_\s]')));
    assert(!attribute.contains(new RegExp(r'[_\s]$')));
    assert(attribute.length <= Trace.maxAttributeKeyLength);
    assert(value.length <= Trace.maxAttributeValueLength);
    assert(_attributes.length < Trace.maxTraceCustomAttributes);

    _attributes.putIfAbsent(attribute, () => value);
    _attributes[attribute] = value;
  }

  /// Removes an already added [attribute].
  ///
  /// If the [HttpMetric] has been stopped, this method throws an assertion
  /// error.
  void removeAttribute(String attribute) {
    assert(!_hasStopped);

    _attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  String getAttribute(String attribute) => _attributes[attribute];
}
