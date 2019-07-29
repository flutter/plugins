// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);
  tearDownAll(() => allTestsCompleter.complete(null));

  test('recordFlutterError', () async {
    // This is currently only testing that we can log errors without crashing.
    final Crashlytics crashlytics = Crashlytics.instance;
    await crashlytics.setUserName('testing');
    await crashlytics.setUserIdentifier('hello');
    crashlytics.setBool('testBool', true);
    crashlytics.setInt('testInt', 42);
    crashlytics.setDouble('testDouble', 42.0);
    crashlytics.setString('testString', 'bar');
    Crashlytics.instance.log('testing');
    await crashlytics.recordFlutterError(FlutterErrorDetails(
        exception: 'testing',
        stack: StackTrace.fromString(''),
        context: DiagnosticsNode.message('during testing'),
        informationCollector: () => <DiagnosticsNode>[
              DiagnosticsNode.message('testing'),
              DiagnosticsNode.message('information'),
            ]));
  });
}
