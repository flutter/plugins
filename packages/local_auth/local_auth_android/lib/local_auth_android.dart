// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:local_auth_platform_interface/types/biometric_type.dart';

export 'package:local_auth_platform_interface/types/biometric_type.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/local_auth_android');

// The implementation of [LocalAuthPlatform] for Android.
class LocalAuthAndroid extends LocalAuthPlatform {
  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthAndroid();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    required Map<String, String> authStrings,
    bool sensitiveTransaction = true,
    bool biometricOnly = false,
  }) async {
    assert(localizedReason.isNotEmpty);
    final Map<String, Object> args = <String, Object>{
      'localizedReason': localizedReason,
      'useErrorDialogs': useErrorDialogs,
      'stickyAuth': stickyAuth,
      'sensitiveTransaction': sensitiveTransaction,
      'biometricOnly': biometricOnly,
    };
    args.addAll(authStrings);
    return (await _channel.invokeMethod<bool>('authenticate', args)) ?? false;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final List<String> result = (await _channel.invokeListMethod<String>(
          'getAvailableBiometrics',
        )) ??
        <String>[];
    final List<BiometricType> biometrics = <BiometricType>[];
    for (final String value in result) {
      switch (value) {
        case 'face':
          biometrics.add(BiometricType.face);
          break;
        case 'fingerprint':
          biometrics.add(BiometricType.fingerprint);
          break;
        case 'iris':
          biometrics.add(BiometricType.iris);
          break;
        case 'undefined':
          break;
      }
    }
    return biometrics;
  }

  @override
  Future<bool> isDeviceSupported() async =>
      (await _channel.invokeMethod<bool>('isDeviceSupported')) ?? false;

  @override
  Future<bool> stopAuthentication() async =>
      await _channel.invokeMethod<bool>('stopAuthentication') ?? false;
}
