// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:local_auth_platform_interface/types/auth_strings.dart';

/// iOS side authentication messages.
///
/// Provides default values for all messages.
class IOSAuthMessages {
  /// Constructs a new instance.
  const IOSAuthMessages({
    this.lockOut,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.cancelButton,
  });

  /// Message advising the user to re-enable biometrics on their device.
  /// It shows in a dialog on iOS.
  final String? lockOut;

  /// Message shown on a button that the user can click to go to settings pages
  /// from the current dialog. It is used on both Android and iOS sides.
  /// Maximum 30 characters.
  final String? goToSettingsButton;

  /// Message advising the user to go to the settings and configure Biometrics
  /// for their device. It shows in a dialog on iOS.
  final String? goToSettingsDescription;

  /// Message shown on a button that the user can click to leave the current
  /// dialog. It is used on iOS.
  /// Maximum 30 characters.
  final String? cancelButton;

  /// Gets the messaged stored in this class instance as a string map.
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

/// Message advising the user to re-enable biometrics on their device.
/// It shows in a dialog on iOS.
String get iOSLockOut => Intl.message(
    'Biometric authentication is disabled. Please lock and unlock your screen to '
    'enable it.',
    desc:
        'Message advising the user to re-enable biometrics on their device. It '
        'shows in a dialog on the iOS.');

/// Message advising the user to go to the settings and configure Biometrics
/// for their device. It shows in a dialog on iOS.
String get iOSGoToSettingsDescription => Intl.message(
    'Biometric authentication is not set up on your device. Please either enable '
    'Touch ID or Face ID on your phone.',
    desc:
        'Message advising the user to go to the settings and configure Biometrics '
        'for their device. It shows in a dialog on iOS.');

/// Message shown on a button that the user can click to leave the current
/// dialog. It is used on iOS.
/// Maximum 30 characters.
String get iOSOkButton => Intl.message('OK',
    desc: 'Message showed on a button that the user can click to leave the '
        'current dialog. It is used on iOS side. Maximum 30 characters.');
