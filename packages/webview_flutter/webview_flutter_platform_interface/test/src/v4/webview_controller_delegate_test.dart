// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/navigation_callback_handler_delegate.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_controller_delegate.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart';

import 'navigation_callback_handler_delegate_test.dart';
import 'webview_platform_test.mocks.dart';

@GenerateMocks(<Type>[NavigationCallbackHandlerDelegate])
void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    when((WebViewPlatform.instance! as MockWebViewPlatform)
            .createWebViewControllerDelegate(any))
        .thenReturn(ImplementsWebViewControllerDelegate());

    expect(() {
      WebViewControllerDelegate(WebViewControllerCreationParams());
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    when((WebViewPlatform.instance! as MockWebViewPlatform)
            .createWebViewControllerDelegate(any))
        .thenReturn(ExtendsWebViewControllerDelegate());

    expect(WebViewControllerDelegate(WebViewControllerCreationParams()),
        isNotNull);
  });

  test('Can be mocked with `implements`', () {
    when((WebViewPlatform.instance! as MockWebViewPlatform)
            .createWebViewControllerDelegate(any))
        .thenReturn(MockWebViewControllerDelegate());

    expect(WebViewControllerDelegate(WebViewControllerCreationParams()),
        isNotNull);
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadFile should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.loadFile(''),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadFlutterAsset should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.loadFlutterAsset(''),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadHtmlString should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.loadHtmlString(''),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of loadRequest should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.loadRequest(MockLoadRequestParamsDelegate()),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of updateSettings should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.updateSettings(MockWebSettingsDelegate()),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of currentUrl should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.currentUrl(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of canGoBack should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.canGoBack(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of canGoForward should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.canGoForward(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of goBack should throw unimplemented error', () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.goBack(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of goForward should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.goForward(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of reload should throw unimplemented error', () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.reload(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of clearCache should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.clearCache(),
      throwsUnimplementedError,
    );
  });

  test(
    'Default implementation of the setNavigationCallback should throw unimplemented error',
    () {
      final WebViewControllerDelegate controller =
          ExtendsWebViewControllerDelegate();

      expect(
        () => controller.setNavigationCallbackHandler(
            MockNavigationCallbackHandlerDelegate()),
        throwsUnimplementedError,
      );
    },
  );

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of runJavaScript should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.runJavaScript('javaScript'),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of runJavaScriptReturningResult should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.runJavaScriptReturningResult('javaScript'),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of addJavaScriptChannel should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

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
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.removeJavaScriptChannel('test'),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of getTitle should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.getTitle(),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of scrollTo should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.scrollTo(0, 0),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of scrollBy should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.scrollBy(0, 0),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of getScrollPosition should throw unimplemented error',
      () {
    final WebViewControllerDelegate controller =
        ExtendsWebViewControllerDelegate();

    expect(
      () => controller.getScrollPosition(),
      throwsUnimplementedError,
    );
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsWebViewControllerDelegate implements WebViewControllerDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebViewControllerDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        WebViewControllerDelegate {}

class ExtendsWebViewControllerDelegate extends WebViewControllerDelegate {
  ExtendsWebViewControllerDelegate() : super.implementation();
}

// ignore: must_be_immutable
class MockLoadRequestParamsDelegate extends Mock
    with
        //ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        LoadRequestParams {}

class MockWebSettingsDelegate extends Mock
    with
        //ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        WebSettingsDelegate {}
