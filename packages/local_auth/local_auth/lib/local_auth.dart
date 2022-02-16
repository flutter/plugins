// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a temporary ignore to allow us to land a new set of linter rules in a
// series of manageable patches instead of one gigantic PR. It disables some of
// the new lints that are already failing on this plugin, for this plugin. It
// should be deleted and the failing lints addressed as soon as possible.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

import 'auth_strings.dart';
import 'error_codes.dart';

enum BiometricType { face, fingerprint, iris }

const MethodChannel _channel = MethodChannel('plugins.flutter.io/local_auth');

Platform _platform = const LocalPlatform();

@visibleForTesting
void setMockPathProviderPlatform(Platform platform) {
  _platform = platform;
}

/// A Flutter plugin for authenticating the user identity locally.
class LocalAuthentication {
  /// The `authenticateWithBiometrics` method has been deprecated.
  /// Use `authenticate` with `biometricOnly: true` instead
  @Deprecated('Use `authenticate` with `biometricOnly: true` instead')
  Future<bool> authenticateWithBiometrics({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    AndroidAuthMessages androidAuthStrings = const AndroidAuthMessages(),
    IOSAuthMessages iOSAuthStrings = const IOSAuthMessages(),
    bool sensitiveTransaction = true,
  }) =>
      authenticate(
        localizedReason: localizedReason,
        useErrorDialogs: useErrorDialogs,
        stickyAuth: stickyAuth,
        androidAuthStrings: androidAuthStrings,
        iOSAuthStrings: iOSAuthStrings,
        sensitiveTransaction: sensitiveTransaction,
        biometricOnly: true,
      );

  /// Authenticates the user with biometrics available on the device while also
  /// allowing the user to use device authentication - pin, pattern, passcode.
  ///
  /// Returns a [Future] holding true, if the user successfully authenticated,
  /// false otherwise.
  ///
  /// [localizedReason] is the message to show to user while prompting them
  /// for authentication. This is typically along the lines of: 'Please scan
  /// your finger to access MyApp.'. This must not be empty.
  ///
  /// [useErrorDialogs] = true means the system will attempt to handle user
  /// fixable issues encountered while authenticating. For instance, if
  /// fingerprint reader exists on the phone but there's no fingerprint
  /// registered, the plugin will attempt to take the user to settings to add
  /// one. Anything that is not user fixable, such as no biometric sensor on
  /// device, will be returned as a [PlatformException].
  ///
  /// [stickyAuth] is used when the application goes into background for any
  /// reason while the authentication is in progress. Due to security reasons,
  /// the authentication has to be stopped at that time. If stickyAuth is set
  /// to true, authentication resumes when the app is resumed. If it is set to
  /// false (default), then as soon as app is paused a failure message is sent
  /// back to Dart and it is up to the client app to restart authentication or
  /// do something else.
  ///
  /// Construct [AndroidAuthStrings] and [IOSAuthStrings] if you want to
  /// customize messages in the dialogs.
  ///
  /// Setting [sensitiveTransaction] to true enables platform specific
  /// precautions. For instance, on face unlock, Android opens a confirmation
  /// dialog after the face is recognized to make sure the user meant to unlock
  /// their phone.
  ///
  /// Setting [biometricOnly] to true prevents authenticates from using non-biometric
  /// local authentication such as pin, passcode, and passcode.
  ///
  /// Throws an [PlatformException] if there were technical problems with local
  /// authentication (e.g. lack of relevant hardware). This might throw
  /// [PlatformException] with error code [otherOperatingSystem] on the iOS
  /// simulator.
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    AndroidAuthMessages androidAuthStrings = const AndroidAuthMessages(),
    IOSAuthMessages iOSAuthStrings = const IOSAuthMessages(),
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
    if (_platform.isIOS) {
      args.addAll(iOSAuthStrings.args);
    } else if (_platform.isAndroid) {
      args.addAll(androidAuthStrings.args);
    } else {
      throw PlatformException(
        code: otherOperatingSystem,
        message: 'Local authentication does not support non-Android/iOS '
            'operating systems.',
        details: 'Your operating system is ${_platform.operatingSystem}',
      );
    }
    return (await _channel.invokeMethod<bool>('authenticate', args)) ?? false;
  }

  /// Returns true if auth was cancelled successfully.
  /// This api only works for Android.
  /// Returns false if there was some error or no auth in progress.
  ///
  /// Returns [Future] bool true or false:
  Future<bool> stopAuthentication() async {
    if (_platform.isAndroid) {
      return await _channel.invokeMethod<bool>('stopAuthentication') ?? false;
    }
    return true;
  }

  /// Returns true if device is capable of checking biometrics
  ///
  /// Returns a [Future] bool true or false:
  Future<bool> get canCheckBiometrics async =>
      (await _channel.invokeListMethod<String>('getAvailableBiometrics'))!
          .isNotEmpty;

  /// Returns true if device is capable of checking biometrics or is able to
  /// fail over to device credentials.
  ///
  /// Returns a [Future] bool true or false:
  Future<bool> isDeviceSupported() async =>
      (await _channel.invokeMethod<bool>('isDeviceSupported')) ?? false;

  /// Returns a list of enrolled biometrics
  ///
  /// Returns a [Future] List<BiometricType> with the following possibilities:
  /// - BiometricType.face
  /// - BiometricType.fingerprint
  /// - BiometricType.iris (not yet implemented)
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
}
