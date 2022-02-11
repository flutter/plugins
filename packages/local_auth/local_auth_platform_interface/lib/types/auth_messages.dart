// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Abstract class for storing platform specific strings.
abstract class AuthMessages {
  /// Constructs an instance of [AuthMessages].
  const AuthMessages();

  /// Returns all platform-specific messages as a map.
  Map<String, String> get args;
}
