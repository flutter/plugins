// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion ErrorHandling
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
// #enddocregion ErrorHandling

void main() async {
// #docregion ErrorHandling
  final LocalAuthentication auth = LocalAuthentication();
// #enddocregion ErrorHandling

// #docregion ErrorHandling
  try {
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance');
    print(didAuthenticate ? 'Success!' : 'Failure');
  } on PlatformException catch (e) {
    if (e.code == auth_error.notAvailable) {
      // Add handling of no hardware here.
    } else {
      // ...
    }
  }
// #enddocregion ErrorHandling
}
