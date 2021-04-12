// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAuth', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/local_auth',
    );

    final List<MethodCall> log = <MethodCall>[];
    late LocalAuthentication localAuthentication;

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return Future<dynamic>.value(true);
      });
      localAuthentication = LocalAuthentication();
      log.clear();
    });

    group("With device auth fail over", () {
      test('authenticate with no args on Android.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'android'));
        await localAuthentication.authenticate(
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

      test('authenticate with no args on iOS.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));
        await localAuthentication.authenticate(
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
                }..addAll(const IOSAuthMessages().args)),
          ],
        );
      });

      test('authenticate with no localizedReason on iOS.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));
        await expectLater(
          localAuthentication.authenticate(
            localizedReason: '',
            biometricOnly: true,
          ),
          throwsAssertionError,
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'android'));
        await localAuthentication.authenticate(
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

    group("With biometrics only", () {
      test('authenticate with no args on Android.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'android'));
        await localAuthentication.authenticate(
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

      test('authenticate with no args on iOS.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));
        await localAuthentication.authenticate(
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
                }..addAll(const IOSAuthMessages().args)),
          ],
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        setMockPathProviderPlatform(FakePlatform(operatingSystem: 'android'));
        await localAuthentication.authenticate(
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
