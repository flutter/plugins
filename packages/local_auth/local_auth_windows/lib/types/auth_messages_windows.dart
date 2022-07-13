// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';

/// Windows side authentication messages.
///
/// Provides default values for all messages.
///
/// Currently unused.
@immutable
class WindowsAuthMessages extends AuthMessages {
  /// Constructs a new instance.
  const WindowsAuthMessages();

  @override
  Map<String, String> get args {
    return <String, String>{};
  }
}
