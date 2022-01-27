// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:local_auth_platform_interface/default_method_channel_platform.dart';
import 'package:local_auth_platform_interface/types/auth_options.dart';
import 'package:local_auth_platform_interface/types/biometric_type.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of local_auth must implement.
///
/// Platform implementations should extend this class rather than implement it as `local_auth`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [LocalAuthPlatform] methods.
abstract class LocalAuthPlatform extends PlatformInterface {
  /// Constructs a LocalAuthPlatform.
  LocalAuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalAuthPlatform _instance = DefaultLocalAuthPlatform();

  /// The default instance of [LocalAuthPlatform] to use.
  ///
  /// Defaults to [DefaultLocalAuthPlatform].
  static LocalAuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalAuthPlatform] when they
  /// register themselves.
  static set instance(LocalAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

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
  /// Provide [authStrings] if you want to
  /// customize messages in the dialogs.
  ///
  /// Provide [options] for configuring further authentication related options.
  ///
  /// Throws an [PlatformException] if there were technical problems with local
  /// authentication (e.g. lack of relevant hardware). This might throw
  /// [PlatformException] with error code [otherOperatingSystem] on the iOS
  /// simulator.
  Future<bool> authenticate({
    required String localizedReason,
    required Map<String, String> authStrings,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  /// Returns a list of enrolled biometrics.
  ///
  /// Returns a [Future] List<BiometricType> with the following possibilities:
  /// - BiometricType.face
  /// - BiometricType.fingerprint
  /// - BiometricType.iris (not yet implemented)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    throw UnimplementedError(
        'getAvailableBiometrics() has not been implemented.');
  }

  /// Returns true if device is capable of checking biometrics or is able to
  /// fail over to device credentials.
  ///
  /// Returns a [Future] bool true or false:
  Future<bool> isDeviceSupported() async {
    throw UnimplementedError('isDeviceSupported() has not been implemented.');
  }

  /// Returns true if auth was cancelled successfully.
  /// Returns false if there was some error or no auth in progress.
  ///
  /// Returns [Future] bool true or false:
  Future<bool> stopAuthentication() async {
    throw UnimplementedError('stopAuthentication() has not been implemented.');
  }
}
