// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:local_auth_android/types/auth_messages_android.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

export 'package:local_auth_android/types/auth_messages_android.dart';
export 'package:local_auth_platform_interface/types/auth_messages.dart';
export 'package:local_auth_platform_interface/types/auth_options.dart';
export 'package:local_auth_platform_interface/types/biometric_type.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/local_auth_android');

/// The implementation of [LocalAuthPlatform] for Android.
class LocalAuthAndroid extends LocalAuthPlatform {
  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthAndroid();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    assert(localizedReason.isNotEmpty);
    final Map<String, Object> args = <String, Object>{
      'localizedReason': localizedReason,
      'useErrorDialogs': options.useErrorDialogs,
      'stickyAuth': options.stickyAuth,
      'sensitiveTransaction': options.sensitiveTransaction,
      'biometricOnly': options.biometricOnly,
    };
    args.addAll(const AndroidAuthMessages().args);
    for (final AuthMessages messages in authMessages) {
      if (messages is AndroidAuthMessages) {
        args.addAll(messages.args);
      }
    }
    return (await _channel.invokeMethod<bool>('authenticate', args)) ?? false;
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    return (await _channel.invokeMethod<bool>('deviceSupportsBiometrics')) ??
        false;
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    final List<String> result = (await _channel.invokeListMethod<String>(
          'getEnrolledBiometrics',
        )) ??
        <String>[];
    final List<BiometricType> biometrics = <BiometricType>[];
    for (final String value in result) {
      switch (value) {
        case 'weak':
          biometrics.add(BiometricType.weak);
          break;
        case 'strong':
          biometrics.add(BiometricType.strong);
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
