// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_windows/local_auth_windows.dart';
import 'package:local_auth_windows/src/messages.g.dart';

void main() {
  group('authenticate', () {
    late _FakeLocalAuthApi api;
    late LocalAuthWindows plugin;

    setUp(() {
      api = _FakeLocalAuthApi();
      plugin = LocalAuthWindows(api: api);
    });

    test('authenticate handles success', () async {
      api.returnValue = true;

      final bool result = await plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason');

      expect(result, true);
      expect(api.passedReason, 'My localized reason');
    });

    test('authenticate handles failure', () async {
      api.returnValue = false;

      final bool result = await plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason');

      expect(result, false);
      expect(api.passedReason, 'My localized reason');
    });

    test('authenticate throws for biometricOnly', () async {
      expect(
          plugin.authenticate(
              authMessages: <AuthMessages>[const WindowsAuthMessages()],
              localizedReason: 'My localized reason',
              options: const AuthenticationOptions(biometricOnly: true)),
          throwsA(isUnsupportedError));
    });

    test('isDeviceSupported handles supported', () async {
      api.returnValue = true;

      final bool result = await plugin.isDeviceSupported();

      expect(result, true);
    });

    test('isDeviceSupported handles unsupported', () async {
      api.returnValue = false;

      final bool result = await plugin.isDeviceSupported();

      expect(result, false);
    });

    test('deviceSupportsBiometrics handles supported', () async {
      api.returnValue = true;

      final bool result = await plugin.deviceSupportsBiometrics();

      expect(result, true);
    });

    test('deviceSupportsBiometrics handles unsupported', () async {
      api.returnValue = false;

      final bool result = await plugin.deviceSupportsBiometrics();

      expect(result, false);
    });

    test('getEnrolledBiometrics returns expected values when supported',
        () async {
      api.returnValue = true;

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[BiometricType.weak, BiometricType.strong]);
    });

    test('getEnrolledBiometrics returns nothing when unsupported', () async {
      api.returnValue = false;

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, isEmpty);
    });

    test('stopAuthentication returns false', () async {
      final bool result = await plugin.stopAuthentication();

      expect(result, false);
    });
  });
}

class _FakeLocalAuthApi implements LocalAuthApi {
  /// The return value for [isDeviceSupported] and [authenticate].
  bool returnValue = false;

  /// The argument that was passed to [authenticate].
  String? passedReason;

  @override
  Future<bool> authenticate(String localizedReason) async {
    passedReason = localizedReason;
    return returnValue;
  }

  @override
  Future<bool> isDeviceSupported() async {
    return returnValue;
  }
}
