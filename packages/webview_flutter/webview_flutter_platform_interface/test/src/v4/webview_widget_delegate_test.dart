// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/v4/src/webview_controller_delegate.dart';
import 'package:webview_flutter_platform_interface/v4/src/webview_platform.dart';
import 'package:webview_flutter_platform_interface/v4/src/webview_widget_delegate.dart';

import 'webview_platform_test.mocks.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    final MockWebViewControllerDelegate controller =
        MockWebViewControllerDelegate();
    final WebViewWidgetCreationParams params =
        WebViewWidgetCreationParams(controller: controller);
    when(WebViewPlatform.instance!.createWebViewWidgetDelegate(params))
        .thenReturn(ImplementsWebViewWidgetDelegate());

    expect(() {
      WebViewWidgetDelegate(params);
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    final MockWebViewControllerDelegate controller =
        MockWebViewControllerDelegate();
    final WebViewWidgetCreationParams params =
        WebViewWidgetCreationParams(controller: controller);
    when(WebViewPlatform.instance!.createWebViewWidgetDelegate(params))
        .thenReturn(ExtendsWebViewWidgetDelegate(params));

    expect(WebViewWidgetDelegate(params), isNotNull);
  });

  test('Can be mocked with `implements`', () {
    final MockWebViewControllerDelegate controller =
        MockWebViewControllerDelegate();
    final WebViewWidgetCreationParams params =
        WebViewWidgetCreationParams(controller: controller);
    when(WebViewPlatform.instance!.createWebViewWidgetDelegate(params))
        .thenReturn(MockWebViewWidgetDelegate());

    expect(WebViewWidgetDelegate(params), isNotNull);
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsWebViewWidgetDelegate implements WebViewWidgetDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebViewWidgetDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        WebViewWidgetDelegate {}

class ExtendsWebViewWidgetDelegate extends WebViewWidgetDelegate {
  ExtendsWebViewWidgetDelegate(WebViewWidgetCreationParams params)
      : super.implementation(params);

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError(
        'build is not implemented for ExtendedWebViewWidgetDelegate.');
  }
}

class MockWebViewControllerDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        WebViewControllerDelegate {}
