// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/navigation_callback_handler_delegate.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart';

import 'webview_platform_test.mocks.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    when(WebViewPlatform.instance!.createNavigationCallbackHandlerDelegate())
        .thenReturn(ImplementsNavigationCallbackHandlerDelegate());

    expect(() {
      NavigationCallbackHandlerDelegate();
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    when(WebViewPlatform.instance!.createNavigationCallbackHandlerDelegate())
        .thenReturn(ExtendsNavigationCallbackHandlerDelegate());

    expect(NavigationCallbackHandlerDelegate(), isNotNull);
  });

  test('Can be mocked with `implements`', () {
    when(WebViewPlatform.instance!.createNavigationCallbackHandlerDelegate())
        .thenReturn(MockNavigationCallbackHandlerDelegate());

    expect(NavigationCallbackHandlerDelegate(), isNotNull);
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setOnNavigationRequest should throw unimplemented error',
      () {
    final NavigationCallbackHandlerDelegate callbackHandler =
        ExtendsNavigationCallbackHandlerDelegate();

    expect(
      () => callbackHandler.setOnNavigationRequest(
          ({required bool isForMainFrame, required String url}) {}),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setOnPageStarted should throw unimplemented error',
      () {
    final NavigationCallbackHandlerDelegate callbackHandler =
        ExtendsNavigationCallbackHandlerDelegate();

    expect(
      () => callbackHandler.setOnPageStarted((String url) {}),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setOnPageFinished should throw unimplemented error',
      () {
    final NavigationCallbackHandlerDelegate callbackHandler =
        ExtendsNavigationCallbackHandlerDelegate();

    expect(
      () => callbackHandler.setOnPageFinished((String url) {}),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setOnProgress should throw unimplemented error',
      () {
    final NavigationCallbackHandlerDelegate callbackHandler =
        ExtendsNavigationCallbackHandlerDelegate();

    expect(
      () => callbackHandler.setOnProgress((int progress) {}),
      throwsUnimplementedError,
    );
  });

  test(
      // ignore: lines_longer_than_80_chars
      'Default implementation of setOnWebResourceError should throw unimplemented error',
      () {
    final NavigationCallbackHandlerDelegate callbackHandler =
        ExtendsNavigationCallbackHandlerDelegate();

    expect(
      () => callbackHandler
          .setOnWebResourceError((WebResourceErrorDelegate error) {}),
      throwsUnimplementedError,
    );
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsNavigationCallbackHandlerDelegate
    implements NavigationCallbackHandlerDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockNavigationCallbackHandlerDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        NavigationCallbackHandlerDelegate {}

class ExtendsNavigationCallbackHandlerDelegate
    extends NavigationCallbackHandlerDelegate {
  ExtendsNavigationCallbackHandlerDelegate() : super.implementation();
}
