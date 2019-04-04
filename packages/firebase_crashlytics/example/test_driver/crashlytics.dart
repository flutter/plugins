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

  test('onError', () async {
    // This is currently only testing that we can log errors without crashing.
    await Crashlytics.instance.setUserName('testing');
    await Crashlytics.instance.setUserIdentifier('hello');
    Crashlytics.instance.log('testing');
    await Crashlytics.instance.onError(
      FlutterErrorDetails(
        exception: 'testing',
        stack: StackTrace.fromString(''),
      ),
    );
  });
}
