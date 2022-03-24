// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart';

import '../webview_platform_test.mocks.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    final Uri testUri = Uri(path: 'https://flutter.dev');
    const LoadRequestMethod testMethod = LoadRequestMethod.get;
    final Map<String, String> testHeaders = <String, String>{};
    when(WebViewPlatform.instance!.createLoadRequestParamsDelegate(
      uri: testUri,
      method: testMethod,
      headers: testHeaders,
    )).thenReturn(ImplementsLoadRequestParamsDelegate());

    expect(() {
      LoadRequestParamsDelegate(
        uri: testUri,
        method: testMethod,
        headers: testHeaders,
      );
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    final Uri testUri = Uri(path: 'https://flutter.dev');
    const LoadRequestMethod testMethod = LoadRequestMethod.get;
    final Map<String, String> testHeaders = <String, String>{};
    when(WebViewPlatform.instance!.createLoadRequestParamsDelegate(
      uri: testUri,
      method: testMethod,
      headers: testHeaders,
    )).thenReturn(ExtendsLoadRequestParamsDelegate(
      uri: testUri,
      method: testMethod,
      headers: testHeaders,
    ));

    expect(
        ExtendsLoadRequestParamsDelegate(
          uri: testUri,
          method: testMethod,
          headers: testHeaders,
        ),
        isNotNull);
  });

  test('Can be mocked with `implements`', () {
    final Uri testUri = Uri(path: 'https://flutter.dev');
    const LoadRequestMethod testMethod = LoadRequestMethod.get;
    final Map<String, String> testHeaders = <String, String>{};
    when(WebViewPlatform.instance!.createLoadRequestParamsDelegate(
      uri: testUri,
      method: testMethod,
      headers: testHeaders,
    )).thenReturn(MockLoadRequestParamsDelegate());

    expect(
        ExtendsLoadRequestParamsDelegate(
          uri: testUri,
          method: testMethod,
          headers: testHeaders,
        ),
        isNotNull);
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsLoadRequestParamsDelegate implements LoadRequestParamsDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLoadRequestParamsDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        LoadRequestParamsDelegate {}

class ExtendsLoadRequestParamsDelegate extends LoadRequestParamsDelegate {
  ExtendsLoadRequestParamsDelegate({
    required Uri uri,
    required LoadRequestMethod method,
    required Map<String, String> headers,
    Uint8List? body,
  }) : super.implementation(
          uri: uri,
          method: method,
          headers: headers,
          body: body,
        );
}
