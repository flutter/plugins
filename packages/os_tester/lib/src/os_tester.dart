// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of os_tester;

/// This global makes it easy to concisely get an OSTester for use in tests.
OSTester os = OSTester();

class OSTester {
  static const MethodChannel _channel = MethodChannel('plugins.flutter.io/os_tester');

  /// Taps the element matched by [matcher]
  Future<bool> tap(Matcher matcher) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await _channel.invokeMethod('tap', <String, dynamic>{ 'matcher': matcher._data });
  }

  /// Asserts that [actual] matches [matcher].
  Future<bool> expect(Matcher actual, Matcher matcher) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await _channel.invokeMethod('expect', <String, dynamic>{
      'actual': actual._data,
      'matcher': matcher._data,
    });
  }

  /// Matches an element with the specified label value
  Matcher label(String text) => Matcher._label(text);

  /// Matches an element with the specified text value
  Matcher text(String text) => Matcher._text(text);

  /// Matches an element that is sufficiently visible
  Matcher get visible => Matcher._visible();
}
