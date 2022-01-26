// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:local_auth_platform_interface/types/auth_strings.dart';

/// Android side authentication messages.
///
/// Provides default values for all messages.
class AndroidAuthMessages {
  /// Constructs a new instance.
  const AndroidAuthMessages({
    this.biometricHint,
    this.biometricNotRecognized,
    this.biometricRequiredTitle,
    this.biometricSuccess,
    this.cancelButton,
    this.deviceCredentialsRequiredTitle,
    this.deviceCredentialsSetupDescription,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.signInTitle,
  });

  /// Hint message advising the user how to authenticate with biometrics. It is
  /// used on Android. Maximum 60 characters.
  final String? biometricHint;

  /// Message to let the user know that authentication was failed. It is used
  /// on Android. Maximum 60 characters.'
  final String? biometricNotRecognized;

  /// Message shown as a title in a dialog which indicates the user
  /// has not set up biometric authentication on their device. It is used on
  /// Android. Maximum 60 characters.
  final String? biometricRequiredTitle;

  /// Message to let the user know that authentication was successful. It
  /// is used on Android. Maximum 60 characters
  final String? biometricSuccess;

  /// Message shown on a button that the user can click to leave the
  /// current dialog. It is used on Android. Maximum 30 characters.
  final String? cancelButton;

  /// Message shown as a title in a dialog which indicates the user
  /// has not set up credentials authentication on their device. It is used on Android.
  /// Maximum 60 characters.
  final String? deviceCredentialsRequiredTitle;

  /// Message advising the user to go to the settings and configure
  /// device credentials on their device. It shows in a dialog on Android.
  final String? deviceCredentialsSetupDescription;

  /// Message shown on a button that the user can click to go to settings pages
  /// from the current dialog. It is used on both Android and iOS sides.
  /// Maximum 30 characters.
  final String? goToSettingsButton;

  /// Message advising the user to go to the settings and configure
  /// biometric on their device. It shows in a dialog on Android.
  final String? goToSettingsDescription;

  /// Message shown as a title in a dialog which indicates the user
  /// that they need to scan biometric to continue. It is used on
  /// Android. Maximum 60 characters.
  final String? signInTitle;

  /// Gets the messaged stored in this class instance as a string map.
  Map<String, String> get args {
    return <String, String>{
      'biometricHint': biometricHint ?? androidBiometricHint,
      'biometricNotRecognized':
          biometricNotRecognized ?? androidBiometricNotRecognized,
      'biometricSuccess': biometricSuccess ?? androidBiometricSuccess,
      'biometricRequired':
          biometricRequiredTitle ?? androidBiometricRequiredTitle,
      'cancelButton': cancelButton ?? androidCancelButton,
      'deviceCredentialsRequired': deviceCredentialsRequiredTitle ??
          androidDeviceCredentialsRequiredTitle,
      'deviceCredentialsSetupDescription': deviceCredentialsSetupDescription ??
          androidDeviceCredentialsSetupDescription,
      'goToSetting': goToSettingsButton ?? goToSettings,
      'goToSettingDescription':
          goToSettingsDescription ?? androidGoToSettingsDescription,
      'signInTitle': signInTitle ?? androidSignInTitle,
    };
  }
}

// Strings for local_authentication plugin. Currently supports English.
// Intl.message must be string literals.

/// Hint message advising the user how to authenticate with biometrics. It is
/// used on Android. Maximum 60 characters.
String get androidBiometricHint => Intl.message('Verify identity',
    desc:
        'Hint message advising the user how to authenticate with biometrics. It is '
        'used on Android. Maximum 60 characters.');

/// Message to let the user know that authentication was failed. It is used
/// on Android. Maximum 60 characters.'
String get androidBiometricNotRecognized =>
    Intl.message('Not recognized. Try again.',
        desc: 'Message to let the user know that authentication was failed. It '
            'is used on Android. Maximum 60 characters.');

/// Message to let the user know that authentication was successful. It
/// is used on Android. Maximum 60 characters
String get androidBiometricSuccess => Intl.message('Success',
    desc: 'Message to let the user know that authentication was successful. It '
        'is used on Android. Maximum 60 characters.');

/// Message shown on a button that the user can click to leave the
/// current dialog. It is used on Android. Maximum 30 characters.
String get androidCancelButton => Intl.message('Cancel',
    desc: 'Message shown on a button that the user can click to leave the '
        'current dialog. It is used on Android. Maximum 30 characters.');

/// Message shown as a title in a dialog which indicates the user
/// that they need to scan biometric to continue. It is used on
/// Android. Maximum 60 characters.
String get androidSignInTitle => Intl.message('Authentication required',
    desc: 'Message shown as a title in a dialog which indicates the user '
        'that they need to scan biometric to continue. It is used on '
        'Android. Maximum 60 characters.');

/// Message shown as a title in a dialog which indicates the user
/// has not set up biometric authentication on their device. It is used on
/// Android. Maximum 60 characters.
String get androidBiometricRequiredTitle => Intl.message('Biometric required',
    desc: 'Message shown as a title in a dialog which indicates the user '
        'has not set up biometric authentication on their device. It is used on Android.'
        ' Maximum 60 characters.');

/// Message shown as a title in a dialog which indicates the user
/// has not set up credentials authentication on their device. It is used on Android.
/// Maximum 60 characters.
String get androidDeviceCredentialsRequiredTitle => Intl.message(
    'Device credentials required',
    desc: 'Message shown as a title in a dialog which indicates the user '
        'has not set up credentials authentication on their device. It is used on Android.'
        ' Maximum 60 characters.');

/// Message advising the user to go to the settings and configure
/// device credentials on their device. It shows in a dialog on Android.
String get androidDeviceCredentialsSetupDescription => Intl.message(
    'Device credentials required',
    desc: 'Message advising the user to go to the settings and configure '
        'device credentials on their device. It shows in a dialog on Android.');

/// Message advising the user to go to the settings and configure
/// biometric on their device. It shows in a dialog on Android.
String get androidGoToSettingsDescription => Intl.message(
    'Biometric authentication is not set up on your device. Go to '
    '\'Settings > Security\' to add biometric authentication.',
    desc: 'Message advising the user to go to the settings and configure '
        'biometric on their device. It shows in a dialog on Android.');
