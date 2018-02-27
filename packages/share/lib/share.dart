// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _kChannel = const MethodChannel('plugins.flutter.io/share');

/// Summons the platform's share sheet to share text.
///
/// Wraps the platform's native share dialog. Can share a text and/or a URL.
/// It uses the ACTION_SEND Intent on Android and UIActivityViewController
/// on iOS.
///
/// May throw [PlatformException] or [FormatException]
/// from [MethodChannel].
Future<void> share(String text) {
  assert(text != null && text.isNotEmpty);
  return _kChannel.invokeMethod('share', text);
}
