// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of os_tester;

/// This global makes it easy to concisely get an OSTester for use in tests.
OSTester os = OSTester();

class OSTester {
  static const MethodChannel _channel =
  const MethodChannel('plugins.flutter.io/os_tester');

  /// Taps the element matched by [matcher]
  Future<void> tap(Matcher matcher) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('tap', <String, dynamic>{ 'matcher': matcher._data });
  }

  /// Asserts that [actual] matches [matcher].
  Future<void> expect(Matcher actual, Matcher matcher) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('expect', <String, dynamic>{
      'actual': actual._data,
      'matcher': matcher._data,
    });
  }

  /// Matches an element with the specified label value
  Matcher label(String text) {
    return new Matcher._({'label': text });
  }

  /// Matches an element with the specified text value
  Matcher text(String text) {
    return new Matcher._({'text': text });
  }
}
