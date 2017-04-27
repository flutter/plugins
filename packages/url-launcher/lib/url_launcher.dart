// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const _channel = const MethodChannel('plugins.flutter.io/url_launcher');

/// Parse the specified URL string and delegate handling of the same to the
/// underlying platform.
Future<Null> launch(String urlString) {
  return _channel.invokeMethod(
    'launch',
    urlString,
  );
}

Future<bool> canLaunch(String urlString) {
  return _channel.invokeMethod(
    'canLaunch',
    urlString,
  );
}
