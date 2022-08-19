// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/default_method_channel_platform.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/local_auth',
  );

  late List<MethodCall> log;
  late LocalAuthPlatform localAuthentication;

  setUp(() async {
    log = <MethodCall>[];
  });

  test(
      'DefaultLocalAuthPlatform is registered as the default platform implementation',
      () async {
    expect(LocalAuthPlatform.instance,
        const TypeMatcher<DefaultLocalAuthPlatform>());
  });

  test('getAvailableBiometrics', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) {
      log.add(methodCall);
      return Future<dynamic>.value(<String>[]);
    });
    localAuthentication = DefaultLocalAuthPlatform();
    await localAuthentication.getEnrolledBiometrics();
    expect(
      log,
      <Matcher>[
        isMethodCall('getAvailableBiometrics', arguments: null),
      ],
    );
  });

  test('deviceSupportsBiometrics handles special sentinal value', () async {
    // The pre-federation implementation of the platform channels, which the
    // default implementation retains compatibility with for the benefit of any
    // existing unendorsed implementations, used 'undefined' as a special
    // return value from `getAvailableBiometrics` to indicate that nothing was
    // enrolled, but that the hardware does support biometrics.
    channel.setMockMethodCallHandler((MethodCall methodCall) {
      log.add(methodCall);
      return Future<dynamic>.value(<String>['undefined']);
    });

    localAuthentication = DefaultLocalAuthPlatform();
    final bool supportsBiometrics =
        await localAuthentication.deviceSupportsBiometrics();
    expect(supportsBiometrics, true);
    expect(
      log,
      <Matcher>[
        isMethodCall('getAvailableBiometrics', arguments: null),
      ],
    );
  });

  group('Boolean returning methods', () {
    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return Future<dynamic>.value(true);
      });
      localAuthentication = DefaultLocalAuthPlatform();
    });

    test('isDeviceSupported', () async {
      await localAuthentication.isDeviceSupported();
      expect(
        log,
        <Matcher>[
          isMethodCall('isDeviceSupported', arguments: null),
        ],
      );
    });

    test('stopAuthentication', () async {
      await localAuthentication.stopAuthentication();
      expect(
        log,
        <Matcher>[
          isMethodCall('stopAuthentication', arguments: null),
        ],
      );
    });

    group('authenticate with device auth fail over', () {
      test('authenticate with no args.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[],
          localizedReason: 'Needs secure',
          options: const AuthenticationOptions(biometricOnly: true),
        );
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'authenticate',
              arguments: <String, dynamic>{
                'localizedReason': 'Needs secure',
                'useErrorDialogs': true,
                'stickyAuth': false,
                'sensitiveTransaction': true,
                'biometricOnly': true,
              },
            ),
          ],
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[],
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
            isMethodCall(
              'authenticate',
              arguments: <String, dynamic>{
                'localizedReason': 'Insecure',
                'useErrorDialogs': false,
                'stickyAuth': false,
                'sensitiveTransaction': false,
                'biometricOnly': true,
              },
            ),
          ],
        );
      });
    });

    group('authenticate with biometrics only', () {
      test('authenticate with no args.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[],
          localizedReason: 'Needs secure',
        );
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'authenticate',
              arguments: <String, dynamic>{
                'localizedReason': 'Needs secure',
                'useErrorDialogs': true,
                'stickyAuth': false,
                'sensitiveTransaction': true,
                'biometricOnly': false,
              },
            ),
          ],
        );
      });

      test('authenticate with no sensitive transaction.', () async {
        await localAuthentication.authenticate(
          authMessages: <AuthMessages>[],
          localizedReason: 'Insecure',
          options: const AuthenticationOptions(
            sensitiveTransaction: false,
            useErrorDialogs: false,
          ),
        );
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'authenticate',
              arguments: <String, dynamic>{
                'localizedReason': 'Insecure',
                'useErrorDialogs': false,
                'stickyAuth': false,
                'sensitiveTransaction': false,
                'biometricOnly': false,
              },
            ),
          ],
        );
      });
    });
  });
}
