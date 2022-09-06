// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter/src/v4/src/webview_cookie_manager.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'webview_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[PlatformNavigationDelegate])
void main() {
  group('NavigationDelegate', () {
    test('onPageStarted', () async {
      final MockPlatformWebViewCookieManager mockPlatformWebViewCookieManager =
          MockPlatformWebViewCookieManager();
      when(mockPlatformWebViewCookieManager.clearCookies()).thenAnswer(
        (_) => Future<bool>.value(false),
      );

      final WebViewCookieManager cookieManager =
          WebViewCookieManager.fromPlatform(
        mockPlatformWebViewCookieManager,
      );

      await expectLater(cookieManager.clearCookies(), completion(false));
    });
  });
}
