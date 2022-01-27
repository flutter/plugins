// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Various types of biometric authentication.
enum BiometricType {
  /// Face authentication.
  face,

  /// Fingerprint authentication.
  fingerprint,

  /// Iris authentication.
  iris,

  /// Any biometric (e.g. fingerprint, iris, or face) on the device that meets
  /// or exceeds the requirements for Class 3 (formerly Strong), as defined
  /// by the Android CDD. Android only.
  strong,

  /// Any biometric (e.g. fingerprint, iris, or face) on the device that meets
  /// or exceeds the requirements for Class 2 (formerly Weak), as defined
  /// by the Android CDD. Android only.
  weak,
}
