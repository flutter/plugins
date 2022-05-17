// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('authenticate', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/local_auth_windows',
    );

    final List<MethodCall> log = <MethodCall>[];
    late LocalAuthWindows localAuthentication;

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
      localAuthentication = LocalAuthWindows();
      log.clear();
    });

    test('authenticate with no arguments passes expected defaults', () async {
      await localAuthentication.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason');
      expect(
        log,
        <Matcher>[
          isMethodCall('authenticate',
              arguments: <String, dynamic>{
                'localizedReason': 'My localized reason',
                'useErrorDialogs': true,
                'stickyAuth': false,
                'sensitiveTransaction': true,
                'biometricOnly': false,
              }..addAll(const WindowsAuthMessages().args)),
        ],
      );
    });

    test('authenticate passes all options.', () async {
      await localAuthentication.authenticate(
        authMessages: <AuthMessages>[const WindowsAuthMessages()],
        localizedReason: 'My localized reason',
        options: const AuthenticationOptions(
          useErrorDialogs: false,
          stickyAuth: true,
          sensitiveTransaction: false,
          biometricOnly: true,
        ),
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('authenticate',
              arguments: <String, dynamic>{
                'localizedReason': 'My localized reason',
                'useErrorDialogs': false,
                'stickyAuth': true,
                'sensitiveTransaction': false,
                'biometricOnly': true,
              }..addAll(const WindowsAuthMessages().args)),
        ],
      );
    });
  });
}
