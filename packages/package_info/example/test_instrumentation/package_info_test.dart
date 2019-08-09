// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../test/package_info.dart' as test;

/// A subclass of [LiveTestWidgetsFlutterBinding] that reports tests results
/// on a channel to adapt them to native instrumentation test format.
// TODO(jackson): Move to a shared package
class _InstrumentationTestFlutterBinding extends LiveTestWidgetsFlutterBinding {
  _InstrumentationTestFlutterBinding();
  static const MethodChannel _channel = const MethodChannel('dev.flutter/InstrumentationTestFlutterBinding');

  static Map<String, String> _results = <String, String>{};

  @override
  Future<void> runTest(Future<void> testBody(), VoidCallback invariantTester, { String description = '', Duration timeout }) async {
    // TODO(jackson): Report the results individually instead of all at once
    reportTestException = (FlutterErrorDetails details, String testDescription) {
      _results[description] = 'failed';
    };
    await super.runTest(testBody, invariantTester, description: description, timeout: timeout);
    _results[description] ??= 'success';
  }

  static void finish() => _channel.invokeMethod('testFinished', { 'results': _results });
}

void main() {
  _InstrumentationTestFlutterBinding();
  tearDownAll(() {
    _InstrumentationTestFlutterBinding.finish();
  });
  test.main();
}
