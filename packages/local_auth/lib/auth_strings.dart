// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a temporary ignore to allow us to land a new set of linter rules in a
// series of manageable patches instead of one gigantic PR. It disables some of
// the new lints that are already failing on this plugin, for this plugin. It
// should be deleted and the failing lints addressed as soon as possible.
// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';

/// Android side authentication messages.
///
/// Provides default values for all messages.
class AndroidAuthMessages {
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

  final String? biometricHint;
  final String? biometricNotRecognized;
  final String? biometricRequiredTitle;
  final String? biometricSuccess;
  final String? cancelButton;
  final String? deviceCredentialsRequiredTitle;
  final String? deviceCredentialsSetupDescription;
  final String? goToSettingsButton;
  final String? goToSettingsDescription;
  final String? signInTitle;

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

/// iOS side authentication messages.
///
/// Provides default values for all messages.
class IOSAuthMessages {
  const IOSAuthMessages({
    this.lockOut,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.cancelButton,
  });

  final String? lockOut;
  final String? goToSettingsButton;
  final String? goToSettingsDescription;
  final String? cancelButton;

  Map<String, String> get args {
    return <String, String>{
      'lockOut': lockOut ?? iOSLockOut,
      'goToSetting': goToSettingsButton ?? goToSettings,
      'goToSettingDescriptionIOS':
          goToSettingsDescription ?? iOSGoToSettingsDescription,
      'okButton': cancelButton ?? iOSOkButton,
    };
  }
}

// Strings for local_authentication plugin. Currently supports English.
// Intl.message must be string literals.
String get androidBiometricHint => Intl.message('Verify identity',
    desc:
        'Hint message advising the user how to authenticate with biometrics. It is '
        'used on Android side. Maximum 60 characters.');

String get androidBiometricNotRecognized =>
    Intl.message('Not recognized. Try again.',
        desc: 'Message to let the user know that authentication was failed. It '
            'is used on Android side. Maximum 60 characters.');

String get androidBiometricSuccess => Intl.message('Success',
    desc: 'Message to let the user know that authentication was successful. It '
        'is used on Android side. Maximum 60 characters.');

String get androidCancelButton => Intl.message('Cancel',
    desc: 'Message showed on a button that the user can click to leave the '
        'current dialog. It is used on Android side. Maximum 30 characters.');

String get androidSignInTitle => Intl.message('Authentication required',
    desc: 'Message showed as a title in a dialog which indicates the user '
        'that they need to scan biometric to continue. It is used on '
        'Android side. Maximum 60 characters.');

String get androidBiometricRequiredTitle => Intl.message('Biometric required',
    desc: 'Message showed as a title in a dialog which indicates the user '
        'has not set up biometric authentication on their device. It is used on Android'
        ' side. Maximum 60 characters.');

String get androidDeviceCredentialsRequiredTitle => Intl.message(
    'Device credentials required',
    desc: 'Message showed as a title in a dialog which indicates the user '
        'has not set up credentials authentication on their device. It is used on Android'
        ' side. Maximum 60 characters.');

String get androidDeviceCredentialsSetupDescription => Intl.message(
    'Device credentials required',
    desc: 'Message advising the user to go to the settings and configure '
        'device credentials on their device. It shows in a dialog on Android side.');

String get goToSettings => Intl.message('Go to settings',
    desc: 'Message showed on a button that the user can click to go to '
        'settings pages from the current dialog. It is used on both Android '
        'and iOS side. Maximum 30 characters.');

String get androidGoToSettingsDescription => Intl.message(
    'Biometric authentication is not set up on your device. Go to '
    '\'Settings > Security\' to add biometric authentication.',
    desc: 'Message advising the user to go to the settings and configure '
        'biometric on their device. It shows in a dialog on Android side.');

String get iOSLockOut => Intl.message(
    'Biometric authentication is disabled. Please lock and unlock your screen to '
    'enable it.',
    desc:
        'Message advising the user to re-enable biometrics on their device. It '
        'shows in a dialog on iOS side.');

String get iOSGoToSettingsDescription => Intl.message(
    'Biometric authentication is not set up on your device. Please either enable '
    'Touch ID or Face ID on your phone.',
    desc:
        'Message advising the user to go to the settings and configure Biometrics '
        'for their device. It shows in a dialog on iOS side.');

String get iOSOkButton => Intl.message('OK',
    desc: 'Message showed on a button that the user can click to leave the '
        'current dialog. It is used on iOS side. Maximum 30 characters.');
