// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth;

/** Exception codes for `PlatformException` in Flutter returned by `authenticate`. */
class AuthResultErrorCodes {
  /**
   * Indicates that the user has not yet configured a PIN/pattern/password on the device.
   */
  static final String PASSCODE_NOT_SET = "PasscodeNotSet";

  /** Indicates the user has not enrolled any biometrics on the device. */
  static final String NOT_ENROLLED = "NotEnrolled";

  /** Indicates the device does not have hardware support for biometrics. */
  static final String NOT_AVAILABLE = "NotAvailable";

  /** Indicates the device operating system is unsupported. */
  static final String OTHER_OPERATING_SYSTEM = "OtherOperatingSystem";

  /** Indicates the API is temporarily locked out due to too many attempts. */
  static final String LOCKED_OUT = "LockedOut";

  /**
   * Indicates the API is locked out more persistently than {@link #LOCKED_OUT}. Strong authentication like
   * PIN/Pattern/Password is required to unlock.
   */
  static final String PERMANENTLY_LOCKED_OUT = "PermanentlyLockedOut";

  /** Indicates that the biometricOnly parameter can"t be true on Windows */
  static final String BIOMETRIC_ONLY_NOT_SUPPORTED = "biometricOnlyNotSupported";
}
