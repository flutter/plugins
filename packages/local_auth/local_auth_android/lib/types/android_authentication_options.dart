// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:local_auth_android/local_auth_android.dart';

/// Android specific options wrapper for [LocalAuthPlatform.authenticate] parameters.
class AndroidAuthenticationOptions extends AuthenticationOptions {
  /// Constructs a new instance.
  const AndroidAuthenticationOptions({
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
    bool biometricOnly = false,
    this.strongBiometricsOnly = false,
  }) : super(
            useErrorDialogs: useErrorDialogs,
            stickyAuth: stickyAuth,
            sensitiveTransaction: sensitiveTransaction,
            biometricOnly: biometricOnly);

  /// Prevent authentications from using non-biometric local authentication
  /// methods such as pin, passcode, or pattern, as well as weak biometric
  /// methods.
  /// Overrides [biometricOnly] when set to true.
  /// Only supported on API level 30 and above, ignored otherwise.
  final bool strongBiometricsOnly;
}
