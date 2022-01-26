// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_android/types/auth_strings_android.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAuth', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/local_auth_android',
    );

    final List<MethodCall> log = <MethodCall>[];
    late LocalAuthAndroid localAuthentication;

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return Future<dynamic>.value(true);
      });
      localAuthentication = LocalAuthAndroid();
      log.clear();
    });

    group('With device auth fail over', () {
      test('authenticate with no args on Android.', () async {
        await localAuthentication.authenticate(
          authStrings: AndroidAuthMessages().args,
          localizedReason: 'Needs secure',
          biometricOnly: true,
        );
        expect(
          log,
          <Matcher>[
            isMethodCall('authenticate',
                arguments: <String, dynamic>{
                  'localizedReason': 'Needs secure',
                  'useErrorDialogs': true,
                  'stickyAuth': false,
                  'sensitiveTransaction': true,
                  'biometricOnly': true,
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        await localAuthentication.authenticate(
          authStrings: AndroidAuthMessages().args,
          localizedReason: 'Insecure',
          sensitiveTransaction: false,
          useErrorDialogs: false,
          biometricOnly: true,
        );
        expect(
          log,
          <Matcher>[
            isMethodCall('authenticate',
                arguments: <String, dynamic>{
                  'localizedReason': 'Insecure',
                  'useErrorDialogs': false,
                  'stickyAuth': false,
                  'sensitiveTransaction': false,
                  'biometricOnly': true,
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });
    });

    group('With biometrics only', () {
      test('authenticate with no args on Android.', () async {
        await localAuthentication.authenticate(
          authStrings: AndroidAuthMessages().args,
          localizedReason: 'Needs secure',
        );
        expect(
          log,
          <Matcher>[
            isMethodCall('authenticate',
                arguments: <String, dynamic>{
                  'localizedReason': 'Needs secure',
                  'useErrorDialogs': true,
                  'stickyAuth': false,
                  'sensitiveTransaction': true,
                  'biometricOnly': false,
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        await localAuthentication.authenticate(
          authStrings: AndroidAuthMessages().args,
          localizedReason: 'Insecure',
          sensitiveTransaction: false,
          useErrorDialogs: false,
        );
        expect(
          log,
          <Matcher>[
            isMethodCall('authenticate',
                arguments: <String, dynamic>{
                  'localizedReason': 'Insecure',
                  'useErrorDialogs': false,
                  'stickyAuth': false,
                  'sensitiveTransaction': false,
                  'biometricOnly': false,
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });
    });
  });
}
