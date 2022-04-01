// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart';

import '../webview_platform_test.mocks.dart';
import 'web_resource_error_delegate_test.mocks.dart';

@GenerateMocks(<Type>[WebResourceErrorDelegate])
void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    const int errorCode = 401;
    const String description =
        'Error used to test the WebResourceErrorDelegate';
    when(WebViewPlatform.instance!.createWebResourceErrorDelegate(
      errorCode: errorCode,
      description: description,
    )).thenReturn(ImplementsWebResourceErrorDelegate());

    expect(() {
      WebResourceErrorDelegate(
        errorCode: errorCode,
        description: description,
      );
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    const int errorCode = 401;
    const String description =
        'Error used to test the WebResourceErrorDelegate';
    when(WebViewPlatform.instance!.createWebResourceErrorDelegate(
      errorCode: errorCode,
      description: description,
    )).thenReturn(ExtendsWebResourceErrorDelegate(
      errorCode: errorCode,
      description: description,
    ));

    expect(() {
      WebResourceErrorDelegate(
        errorCode: errorCode,
        description: description,
      );
    }, isNotNull);
  });

  test('Can be mocked with `implements`', () {
    const int errorCode = 401;
    const String description =
        'Error used to test the WebResourceErrorDelegate';
    when(WebViewPlatform.instance!.createWebResourceErrorDelegate(
      errorCode: errorCode,
      description: description,
    )).thenReturn(MockWebResourceErrorDelegateWithMixin());

    expect(() {
      WebResourceErrorDelegate(
        errorCode: errorCode,
        description: description,
      );
    }, isNotNull);
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsWebResourceErrorDelegate implements WebResourceErrorDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebResourceErrorDelegateWithMixin extends MockWebResourceErrorDelegate
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ExtendsWebResourceErrorDelegate extends WebResourceErrorDelegate {
  ExtendsWebResourceErrorDelegate({
    required int errorCode,
    required String description,
    WebResourceErrorType? errorType,
  }) : super.implementation(
            errorCode: errorCode,
            description: description,
            errorType: errorType);
}
