// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth_ios/types/auth_strings_ios.dart';
import 'package:local_auth_platform_interface/types/auth_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAuth', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/local_auth_ios',
    );

    final List<MethodCall> log = <MethodCall>[];
    late LocalAuthIOS localAuthentication;

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return Future<dynamic>.value(true);
      });
      localAuthentication = LocalAuthIOS();
      log.clear();
    });

    group('With device auth fail over', () {
      test('authenticate with no args on iOS.', () async {
        await localAuthentication.authenticate(
          authStrings: const IOSAuthMessages().args,
          localizedReason: 'Needs secure',
          options: const AuthenticationOptions(biometricOnly: true),
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
        await expectLater(
          localAuthentication.authenticate(
            authStrings: const IOSAuthMessages().args,
            localizedReason: '',
            options: const AuthenticationOptions(biometricOnly: true),
          ),
          throwsAssertionError,
        );
      });
    });

    group('With biometrics only', () {
      test('authenticate with no args on iOS.', () async {
        await localAuthentication.authenticate(
          authStrings: const IOSAuthMessages().args,
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
        await localAuthentication.authenticate(
          authStrings: const IOSAuthMessages().args,
          localizedReason: 'Insecure',
          options: const AuthenticationOptions(
            sensitiveTransaction: false,
            useErrorDialogs: false,
          ),
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
                }..addAll(const IOSAuthMessages().args)),
          ],
        );
      });
    });
  });
}
