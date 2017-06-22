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
  /// Pass useErrorDialogs = false if you don't want to use default error
  /// dialogs. In that case, errors that can be handled by plugin will be
  /// returned to your application.
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
