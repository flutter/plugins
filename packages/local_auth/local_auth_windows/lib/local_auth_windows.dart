// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import 'src/messages.g.dart';

export 'package:local_auth_platform_interface/types/auth_messages.dart';
export 'package:local_auth_platform_interface/types/auth_options.dart';
export 'package:local_auth_platform_interface/types/biometric_type.dart';
export 'package:local_auth_windows/types/auth_messages_windows.dart';

/// The implementation of [LocalAuthPlatform] for Windows.
class LocalAuthWindows extends LocalAuthPlatform {
  /// Creates a new plugin implementation instance.
  LocalAuthWindows({
    @visibleForTesting LocalAuthApi? api,
  }) : _api = api ?? LocalAuthApi();

  final LocalAuthApi _api;

  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthWindows();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    assert(localizedReason.isNotEmpty);

    if (options.biometricOnly) {
      throw UnsupportedError(
          "Windows doesn't support the biometricOnly parameter.");
    }

    return _api.authenticate(localizedReason);
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    // Biometrics are supported on any supported device.
    return isDeviceSupported();
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    // Windows doesn't support querying specific biometric types. Since the
    // OS considers this a strong authentication API, return weak+strong on
    // any supported device.
    if (await isDeviceSupported()) {
      return <BiometricType>[BiometricType.weak, BiometricType.strong];
    }
    return <BiometricType>[];
  }

  @override
  Future<bool> isDeviceSupported() async => _api.isDeviceSupported();

  /// Always returns false as this method is not supported on Windows.
  @override
  Future<bool> stopAuthentication() async => false;
}
