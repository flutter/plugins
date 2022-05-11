// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/v4/src/platform_navigation_callback_delegate.dart';
import 'package:webview_flutter_platform_interface/v4/src/platform_webview_controller.dart';
import 'package:webview_flutter_platform_interface/v4/src/webview_platform.dart';

import 'platform_navigation_callback_delegate_test.dart';
import 'webview_platform_test.mocks.dart';

@GenerateMocks(<Type>[PlatformNavigationCallbackDelegate])
void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    when((WebViewPlatform.instance! as MockWebViewPlatform)
            .createPlatformWebViewController(any))
        .thenReturn(ImplementsPlatformWebViewController());

    expect(() {
      PlatformWebViewController(const WebViewControllerCreationParams());
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    const WebViewControllerCreationParams params =
        WebViewControllerCreationParams();
    when((WebViewPlatform.instance! as MockWebViewPlatform)
            .createPlatformWebViewController(any))
        .thenReturn(ExtendsPlatformWebViewController(params));

    expect(PlatformWebViewController(params), isNotNull);
  });

  test('Can be mocked with `implements`', () {
    when((WebViewPlatform.instance! as MockWebViewPlatform)
            .createPlatformWebViewController(any))
        .thenReturn(MockWebViewControllerDelegate());

    expect(PlatformWebViewController(const WebViewControllerCreationParams()),
        isNotNull);
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadFile should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.loadFile(''),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadFlutterAsset should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.loadFlutterAsset(''),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadHtmlString should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.loadHtmlString(''),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadRequest should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.loadRequest(MockLoadRequestParamsDelegate()),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of currentUrl should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.currentUrl(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of canGoBack should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.canGoBack(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of canGoForward should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.canGoForward(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of goBack should throw unimplemented error', () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.goBack(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of goForward should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.goForward(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of reload should throw unimplemented error', () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.reload(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of clearCache should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.clearCache(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of clearLocalStorage should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.clearLocalStorage(),
      throwsUnimplementedError,
    );
  });

  test(
    'Default implementation of the setNavigationCallback should throw unimplemented error',
    () {
      final PlatformWebViewController controller =
          ExtendsPlatformWebViewController(
              const WebViewControllerCreationParams());

      expect(
        () => controller
            .setNavigationCallbackDelegate(MockNavigationCallbackDelegate()),
        throwsUnimplementedError,
      );
    },
  );

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of runJavaScript should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.runJavaScript('javaScript'),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of runJavaScriptReturningResult should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.runJavaScriptReturningResult('javaScript'),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of addJavaScriptChannel should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.addJavaScriptChannel(
        JavaScriptChannelParams(
          name: 'test',
          onMessageReceived: (_) {},
        ),
      ),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of removeJavaScriptChannel should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.removeJavaScriptChannel('test'),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of getTitle should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.getTitle(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of scrollTo should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.scrollTo(0, 0),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of scrollBy should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.scrollBy(0, 0),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of getScrollPosition should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.getScrollPosition(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of enableDebugging should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.enableDebugging(true),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of enableGestureNavigation should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.enableGestureNavigation(true),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of enableZoom should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.enableZoom(true),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setBackgroundColor should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.setBackgroundColor(Colors.blue),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setJavaScriptMode should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.setJavaScriptMode(JavaScriptMode.disabled),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setUserAgent should throw unimplemented error',
      () {
    final PlatformWebViewController controller =
        ExtendsPlatformWebViewController(
            const WebViewControllerCreationParams());

    expect(
      () => controller.setUserAgent(null),
      throwsUnimplementedError,
    );
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsPlatformWebViewController implements PlatformWebViewController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebViewControllerDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        PlatformWebViewController {}

class ExtendsPlatformWebViewController extends PlatformWebViewController {
  ExtendsPlatformWebViewController(WebViewControllerCreationParams params)
      : super.implementation(params);
}

// ignore: must_be_immutable
class MockLoadRequestParamsDelegate extends Mock
    with
        //ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        LoadRequestParams {}
