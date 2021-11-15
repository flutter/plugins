// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart';
import 'package:webview_flutter_android/src/android_webview_api_impls.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';
import 'android_webview_api_impls_test.mocks.dart';

@GenerateMocks([InstanceManager, WebViewClient, WebView])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebViewClientFlutterApiImpl', () {
    test('onUrlChanged should call WebViewClient#onUrlChanged', () {
      // Setup
      var mockInstanceManager = MockInstanceManager();
      var mockWebViewClient = MockWebViewClient();
      var mockWebView = MockWebView();
      when(mockInstanceManager.getInstance(1)).thenReturn(mockWebViewClient);
      when(mockInstanceManager.getInstance(2)).thenReturn(mockWebView);
      var impl =
          WebViewClientFlutterApiImpl(instanceManager: mockInstanceManager);
      // Run
      impl.onUrlChanged(1, 2, 'https://flutter.dev/');
      // Verify
      verify(
          mockWebViewClient.onUrlChanged(mockWebView, 'https://flutter.dev/'));
    });
  });
}
