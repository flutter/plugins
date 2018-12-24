// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/url_launcher');

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
/// [enableJavaScript] is an Android only setting. If true, webview enable
/// javascript.
///
/// Note that if any of the above are set to true but the URL is not a web URL,
/// this will throw a [PlatformException].
///
/// [statusBarBrightness] Sets the status bar brightness of the application
/// after opening a link on iOS. Does nothing if no value is passed. This does
/// not handle reseting the previous status bar style.
Future<void> launch(
  String urlString, {
  bool forceSafariVC,
  bool forceWebView,
  bool enableJavaScript,
  Brightness statusBarBrightness,
}) {
  assert(urlString != null);
  final Uri url = Uri.parse(urlString.trimLeft());
  final bool isWebURL = url.scheme == 'http' || url.scheme == 'https';
  if ((forceSafariVC == true || forceWebView == true) && !isWebURL) {
    throw PlatformException(
        code: 'NOT_A_WEB_SCHEME',
        message: 'To use webview or safariVC, you need to pass'
            'in a web URL. This $urlString is not a web URL.');
  }
  bool previousAutomaticSystemUiAdjustment;
  if (statusBarBrightness != null &&
      defaultTargetPlatform == TargetPlatform.iOS) {
    previousAutomaticSystemUiAdjustment =
        WidgetsBinding.instance.renderView.automaticSystemUiAdjustment;
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
    SystemChrome.setSystemUIOverlayStyle(statusBarBrightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }
  return _channel.invokeMethod(
    'launch',
    <String, Object>{
      'url': urlString,
      'useSafariVC': forceSafariVC ?? isWebURL,
      'useWebView': forceWebView ?? false,
      'enableJavaScript': enableJavaScript ?? false,
    },
  ).then((void _) {
    if (statusBarBrightness != null) {
      WidgetsBinding.instance.renderView.automaticSystemUiAdjustment =
          previousAutomaticSystemUiAdjustment;
    }
  });
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

/// Closes the current WebView, if one was previously opened via a call to [launch].
///
/// If [launch] was never called, then this call will not have any effect.
///
/// On Android systems, if [launch] was called without `forceWebView` being set to
/// `true`, this call will not do anything either, simply because there is no
/// WebView available to be closed.
Future<void> closeWebView() async {
  return await _channel.invokeMethod('closeWebView');
}
