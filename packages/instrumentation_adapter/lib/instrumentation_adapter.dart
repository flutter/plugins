// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A subclass of [LiveTestWidgetsFlutterBinding] that reports tests results
/// on a channel to adapt them to native instrumentation test format.
class InstrumentationAdapterFlutterBinding
    extends LiveTestWidgetsFlutterBinding {
  InstrumentationAdapterFlutterBinding() {
    // TODO(jackson): Report test results as they arrive
    tearDownAll(() async {
      try {
        await _channel.invokeMethod<void>(
            'allTestsFinished', <String, dynamic>{'results': _results});
      } on MissingPluginException {
        // Tests were run on the host rather than a device.
      }
      if (!_allTestsPassed.isCompleted) _allTestsPassed.complete(true);
    });
  }

  final Completer<bool> _allTestsPassed = Completer<bool>();

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      InstrumentationAdapterFlutterBinding();
    }
    assert(WidgetsBinding.instance is InstrumentationAdapterFlutterBinding);
    return WidgetsBinding.instance;
  }

  static const MethodChannel _channel =
      MethodChannel('dev.flutter/InstrumentationAdapterFlutterBinding');

  static Map<String, String> _results = <String, String>{};

  // Emulates the Flutter driver extension, returning 'pass' or 'fail'.
  @override
  void initServiceExtensions() {
    super.initServiceExtensions();
    Future<Map<String, dynamic>> callback(Map<String, String> params) async {
      final String command = params['command'];
      Map<String, String> response;
      switch (command) {
        case 'request_data':
          final bool allTestsPassed = await _allTestsPassed.future;
          response = <String, String>{
            'message': allTestsPassed ? 'pass' : 'fail',
          };
          break;
        case 'get_health':
          response = <String, String>{'status': 'ok'};
          break;
        default:
          throw UnimplementedError('$command is not implemented');
      }
      return <String, dynamic>{
        'isError': false,
        'response': response,
      };
    }

    registerServiceExtension(name: 'driver', callback: callback);
  }

  @override
  Future<void> runTest(Future<void> testBody(), VoidCallback invariantTester,
      {String description = '', Duration timeout}) async {
    // TODO(jackson): Report the results individually instead of all at once
    // See https://github.com/flutter/flutter/issues/38985
    final TestExceptionReporter valueBeforeTest = reportTestException;
    reportTestException =
        (FlutterErrorDetails details, String testDescription) {
      _results[description] = 'failed';
      _allTestsPassed.complete(false);
      valueBeforeTest(details, testDescription);
    };
    await super.runTest(testBody, invariantTester,
        description: description, timeout: timeout);
    _results[description] ??= 'success';
  }
}
