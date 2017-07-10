// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'auth_strings.dart';
import 'error_codes.dart';

const MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/local_auth');

/// A Flutter plugin for authenticating the user identity locally.
class LocalAuthentication {
  /// Authenticates the user with biometrics available on the device.
  ///
  /// Returns a [Future] holding true, if the user successfully authenticated,
  /// false otherwise.
  ///
  /// [localizedReason] is the message to show to user while prompting them
  /// for authentication. This is typically along the lines of: 'Please scan
  /// your finger to access MyApp.'
  ///
  /// useErrorDialogs = true means the system will attempt to handle user
  /// fixable issues encountered while authenticating. For instance, if
  /// fingerprint reader exists on the phone but there's no fingerprint
  /// registered, the plugin will attempt to take the user to settings to add
  /// one. Anything that is not user fixable, such as no biometric sensor on
  /// device, will be returned as a [PlatformException].
  ///
  /// Construct [AndroidAuthStrings] and [IOSAuthStrings] if you want to
  /// customize messages in the dialogs.
  ///
  /// Throws an [PlatformException] if there were technical problems with local
  /// authentication (e.g. lack of relevant hardware). This might throw
  /// [PlatformException] with error code [otherOperatingSystem] on the iOS
  /// simulator.
  Future<bool> authenticateWithBiometrics({
    @required String localizedReason,
    bool useErrorDialogs: true,
    AndroidAuthMessages androidAuthStrings: const AndroidAuthMessages(),
    IOSAuthMessages iOSAuthStrings: const IOSAuthMessages(),
  }) {
    assert(localizedReason != null);
    final Map<String, Object> args = <String, Object>{
      'localizedReason': localizedReason,
      'useErrorDialogs': useErrorDialogs,
    };
    if (Platform.isIOS) {
      args.addAll(iOSAuthStrings.args);
    } else if (Platform.isAndroid) {
      args.addAll(androidAuthStrings.args);
    } else {
      throw new PlatformException(
          code: otherOperatingSystem,
          message: 'Local authentication does not support non-Android/iOS '
              'operating systems.',
          details: 'Your operating system is ${Platform.operatingSystem}');
    }
    return _channel.invokeMethod('authenticateWithBiometrics', args);
  }
}
