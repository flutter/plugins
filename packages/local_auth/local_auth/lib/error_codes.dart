// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Exception codes for `PlatformException` returned by
// `authenticate`.

/// Indicates that the user has not yet configured a passcode (iOS) or
/// PIN/pattern/password (Android) on the device.
const String passcodeNotSet = 'PasscodeNotSet';

/// Indicates the user has not enrolled any fingerprints on the device.
const String notEnrolled = 'NotEnrolled';

/// Indicates the device does not have a Touch ID/fingerprint scanner.
const String notAvailable = 'NotAvailable';

/// Indicates the device operating system is not iOS or Android.
const String otherOperatingSystem = 'OtherOperatingSystem';

/// Indicates the API lock out due to too many attempts.
const String lockedOut = 'LockedOut';

/// Indicates the API being disabled due to too many lock outs.
/// Strong authentication like PIN/Pattern/Password is required to unlock.
const String permanentlyLockedOut = 'PermanentlyLockedOut';
