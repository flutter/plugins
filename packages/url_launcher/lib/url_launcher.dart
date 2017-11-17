// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/url_launcher');

/// Parses the specified URL string and delegates handling of it to the
/// underlying platform.
///
/// The returned future completes with a [PlatformException] on invalid URLs and
/// schemes which cannot be handled, that is when [canLaunch] would complete
/// with false.
///
/// [useSafariVC] is only used in iOS. If true, it opens the URL in the Safari
/// view controller. If false, the URL is opened in the default browser of the
/// phone. Set this to false, if you want to use the cookies/context of the
/// main browser of the app (such as SSO flows).
Future<Null> launch(String urlString, {bool useSafariVC: true}) {
  return _channel.invokeMethod(
    'launch',
    <String, Object>{'url': urlString, 'useSafariVC': useSafariVC},
  );
}

/// Checks whether the specified URL can be handled by some app installed on the
/// device.
Future<bool> canLaunch(String urlString) async {
  if (urlString == null) {
    return false;
  }
  return await _channel.invokeMethod(
    'canLaunch',
    <String, Object>{'url': urlString},
  );
}
