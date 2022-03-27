// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Various types of biometric authentication.
/// Some platforms report specific biometric types, while others report only
/// classifications like strong and weak.
enum BiometricType {
  /// Face authentication.
  face,

  /// Fingerprint authentication.
  fingerprint,

  /// Iris authentication.
  iris,

  /// Any biometric (e.g. fingerprint, iris, or face) on the device that the
  /// platform API considers to be strong. For example, on Android this
  /// corresponds to Class 3.
  strong,

  /// Any biometric (e.g. fingerprint, iris, or face) on the device that the
  /// platform API considers to be weak. For example, on Android this
  /// corresponds to Class 2.
  weak,
}
