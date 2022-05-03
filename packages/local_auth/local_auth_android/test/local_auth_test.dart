// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_android/local_auth_android.dart';

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
        switch (methodCall.method) {
          case 'getEnrolledBiometrics':
            return Future<List<String>>.value(<String>['weak', 'strong']);
          default:
            return Future<dynamic>.value(true);
        }
      });
      localAuthentication = LocalAuthAndroid();
      log.clear();
    });

    test('deviceSupportsBiometrics calls platform', () async {
      final bool result = await localAuthentication.deviceSupportsBiometrics();

      expect(
        log,
        <Matcher>[
          isMethodCall('deviceSupportsBiometrics', arguments: null),
        ],
      );
      expect(result, true);
    });

    test('getEnrolledBiometrics calls platform', () async {
      final List<BiometricType> result =
          await localAuthentication.getEnrolledBiometrics();

      expect(
        log,
        <Matcher>[
          isMethodCall('getEnrolledBiometrics', arguments: null),
        ],
      );
      expect(result, <BiometricType>[
        BiometricType.weak,
        BiometricType.strong,
      ]);
    });

    test('isDeviceSupported calls platform', () async {
      await localAuthentication.isDeviceSupported();
      expect(
        log,
        <Matcher>[
          isMethodCall('isDeviceSupported', arguments: null),
        ],
      );
    });

    test('stopAuthentication calls platform', () async {
      await localAuthentication.stopAuthentication();
      expect(
        log,
        <Matcher>[
          isMethodCall('stopAuthentication', arguments: null),
        ],
      );
    });

    group('With device auth fail over', () {
      test('authenticate with no args.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[const AndroidAuthMessages()],
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
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[const AndroidAuthMessages()],
          localizedReason: 'Insecure',
          options: const AuthenticationOptions(
            sensitiveTransaction: false,
            useErrorDialogs: false,
            biometricOnly: true,
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
                  'biometricOnly': true,
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });
    });

    group('With biometrics only', () {
      test('authenticate with no args.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[const AndroidAuthMessages()],
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
          authMessages: <AuthMessages>[const AndroidAuthMessages()],
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
                }..addAll(const AndroidAuthMessages().args)),
          ],
        );
      });
    });
  });
}
