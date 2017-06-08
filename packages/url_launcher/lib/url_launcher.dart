// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('plugins.flutter.io/url_launcher');

/// Parses the specified URL string and delegates handling of it to the
/// underlying platform.
///
/// The returned future completes with a [PlatformException] on invalid URLs and
/// schemes which cannot be handled, that is when [canLaunch] would complete
/// with false.
Future<Null> launch(String urlString) {
  return _channel.invokeMethod(
    'launch',
    urlString,
  );
}

/// Checks whether the specified URL can be handled by some app installed on the
/// device.
Future<bool> canLaunch(String urlString) async {
  if (urlString == null)
    return false;
  return await _channel.invokeMethod(
    'canLaunch',
    urlString,
  );
}
