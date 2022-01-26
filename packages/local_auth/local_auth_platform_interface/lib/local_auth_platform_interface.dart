// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [LocalAuthPlatform] when they register themselves.
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
  /// Provide [authStrings] if you want to
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
    required Map<String, String> authStrings,
    bool sensitiveTransaction = true,
    bool biometricOnly = false,
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

/// The default interface implementation acting as a placeholder for
/// the native implementation to be set.
class DefaultLocalAuthPlatform extends LocalAuthPlatform {}
