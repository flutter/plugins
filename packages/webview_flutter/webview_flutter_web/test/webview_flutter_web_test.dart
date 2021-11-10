// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebWebViewPlatform', () {
    test('build returns a HtmlElementView', () {
      // Setup
      var platform = WebWebViewPlatform();
      // Run
      var widget = platform.build(
        context: MockBuildContext(),
        creationParams: CreationParams(),
        webViewPlatformCallbacksHandler: MockWebViewPlatformCallbacksHandler(),
        javascriptChannelRegistry: null,
      );
      // Verify
      expect(widget, isA<HtmlElementView>());
    });
  });

  group('WebWebViewPlatformController', () {
    test('loadUrl sets url on iframe src attribute', () {
      // Setup
      var mockElement = MockIFrameElement();
      var controller = WebWebViewPlatformController(
        mockElement,
        MockWebViewPlatformCallbacksHandler(),
      );
      // Run
      controller.loadUrl('test url', null);
      // Verify
      verify(mockElement.src = 'test url');
    });
  });
}

class MockIFrameElement extends Mock implements IFrameElement {}

class MockBuildContext extends Mock implements BuildContext {}

class MockCreationParams extends Mock implements CreationParams {}

class MockWebViewPlatformCallbacksHandler extends Mock
    implements WebViewPlatformCallbacksHandler {}
