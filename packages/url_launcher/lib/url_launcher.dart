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
/// [forceSafariVC] is only used in iOS. If unset, the launcher opens web URLs
/// in the safari VC, anything else is opened using the default handler on the
/// platform. If set to true, it opens the URL in the Safari view controller.
/// If false, the URL is opened in the default browser of the phone. Set this to
/// false if you want to use the cookies/context of the main browser of the app
/// (such as SSO flows).
///
/// [forceWebView] is an Android only setting. If null or false, the URL is
/// always launched with the default browser on device. If set to true, the URL
/// is launched in a webview. Unlike iOS, browser context is shared across
/// WebViews.
///
/// Note that if any of the above are set to true but the URL is not a web URL,
/// this will throw a [PlatformException].
Future<void> launch(
  String urlString, {
  bool forceSafariVC,
  bool forceWebView,
}) {
  assert(urlString != null);
  final Uri url = Uri.parse(urlString.trimLeft());
  final bool isWebURL = url.scheme == 'http' || url.scheme == 'https';
  if ((forceSafariVC == true || forceWebView == true) && !isWebURL) {
    throw new PlatformException(
        code: 'NOT_A_WEB_SCHEME',
        message: 'To use webview or safariVC, you need to pass'
            'in a web URL. This $urlString is not a web URL.');
  }
  return _channel.invokeMethod(
    'launch',
    <String, Object>{
      'url': urlString,
      'useSafariVC': forceSafariVC ?? isWebURL,
      'useWebView': forceWebView ?? false,
    },
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
