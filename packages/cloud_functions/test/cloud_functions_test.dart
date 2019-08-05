// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$CloudFunctions', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      CloudFunctions.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebaseFunctions#call':
            return <String, dynamic>{
              'foo': 'bar',
            };
          default:
            return true;
        }
      });
      log.clear();
    });

    test('call', () async {
      await CloudFunctions.instance
          .getHttpsCallable(functionName: 'baz')
          .call();
      final HttpsCallable callable =
          CloudFunctions(app: const FirebaseApp(name: '1337'), region: 'space')
              .getHttpsCallable(functionName: 'qux')
                ..timeout = const Duration(days: 300);
      await callable.call(<String, dynamic>{
        'quux': 'quuz',
      });
      await CloudFunctions.instance
          .useFunctionsEmulator(origin: 'http://localhost:5001')
          .getHttpsCallable(functionName: 'bez')
          .call();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'CloudFunctions#call',
            arguments: <String, dynamic>{
              'app': '[DEFAULT]',
              'region': null,
              'origin': null,
              'functionName': 'baz',
              'timeoutMicroseconds': null,
              'parameters': null,
            },
          ),
          isMethodCall(
            'CloudFunctions#call',
            arguments: <String, dynamic>{
              'app': '1337',
              'region': 'space',
              'origin': null,
              'functionName': 'qux',
              'timeoutMicroseconds': (const Duration(days: 300)).inMicroseconds,
              'parameters': <String, dynamic>{'quux': 'quuz'},
            },
          ),
          isMethodCall(
            'CloudFunctions#call',
            arguments: <String, dynamic>{
              'app': '[DEFAULT]',
              'region': null,
              'origin': 'http://localhost:5001',
              'functionName': 'bez',
              'timeoutMicroseconds': null,
              'parameters': null,
            },
          ),
        ],
      );
    });
  });
}
