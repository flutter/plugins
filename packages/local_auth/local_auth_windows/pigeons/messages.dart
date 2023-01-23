// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  cppOptions: CppOptions(namespace: 'local_auth_windows'),
  cppHeaderOut: 'windows/messages.g.h',
  cppSourceOut: 'windows/messages.g.cpp',
  copyrightHeader: 'pigeons/copyright.txt',
))
@HostApi()
abstract class LocalAuthApi {
  /// Returns true if this device supports authentication.
  @async
  bool isDeviceSupported();

  /// Attempts to authenticate the user with the provided [localizedReason] as
  /// the user-facing explanation for the authorization request.
  ///
  /// Returns true if authorization succeeds, false if it is attempted but is
  /// not successful, and an error if authorization could not be attempted.
  @async
  bool authenticate(String localizedReason);
}
