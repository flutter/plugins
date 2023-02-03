// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/src/webview_platform.dart';

import 'android_webview_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[android_webview.CookieManager])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clearCookies should call android_webview.clearCookies', () async {
    final android_webview.CookieManager mockCookieManager = MockCookieManager();

    when(mockCookieManager.clearCookies())
        .thenAnswer((_) => Future<bool>.value(true));

    final AndroidWebViewCookieManagerCreationParams params =
        AndroidWebViewCookieManagerCreationParams
            .fromPlatformWebViewCookieManagerCreationParams(
                const PlatformWebViewCookieManagerCreationParams());

    final bool hasClearedCookies = await AndroidWebViewCookieManager(params,
            cookieManager: mockCookieManager)
        .clearCookies();

    expect(hasClearedCookies, true);
    verify(mockCookieManager.clearCookies());
  });

  test('setCookie should throw ArgumentError for cookie with invalid path', () {
    final AndroidWebViewCookieManagerCreationParams params =
        AndroidWebViewCookieManagerCreationParams
            .fromPlatformWebViewCookieManagerCreationParams(
                const PlatformWebViewCookieManagerCreationParams());

    final AndroidWebViewCookieManager androidCookieManager =
        AndroidWebViewCookieManager(params, cookieManager: MockCookieManager());

    expect(
      () => androidCookieManager.setCookie(const WebViewCookie(
        name: 'foo',
        value: 'bar',
        domain: 'flutter.dev',
        path: 'invalid;path',
      )),
      throwsA(const TypeMatcher<ArgumentError>()),
    );
  });

  test(
      'setCookie should call android_webview.csetCookie with properly formatted cookie value',
      () {
    final android_webview.CookieManager mockCookieManager = MockCookieManager();
    final AndroidWebViewCookieManagerCreationParams params =
        AndroidWebViewCookieManagerCreationParams
            .fromPlatformWebViewCookieManagerCreationParams(
                const PlatformWebViewCookieManagerCreationParams());

    AndroidWebViewCookieManager(params, cookieManager: mockCookieManager)
        .setCookie(const WebViewCookie(
      name: 'foo&',
      value: 'bar@',
      domain: 'flutter.dev',
    ));

    verify(mockCookieManager.setCookie(
      'flutter.dev',
      'foo%26=bar%40; path=/',
    ));
  });
}
