// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/src/v4/android_navigation_delegate.dart';
import 'package:webview_flutter_android/src/v4/types/android_navigation_delegate_creation_params.dart';
import 'package:webview_flutter_android/src/v4/types/android_web_resource_error.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'android_navigation_delegate_test.mocks.dart';

@GenerateMocks(<Type>[
  android_webview.WebView,
  android_webview.WebResourceRequest,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidNavigationDelegate', () {
    test(
        'setOnNavigationRequest should register callbacks with AndroidWebViewClient',
        () {
      final AndroidNavigationDelegateCreationParams params =
          _buildCreationParams();
      final AndroidNavigationDelegate navigationDelegate =
          AndroidNavigationDelegate.fromNativeApi(
        params,
      );

      FutureOr<bool> onNavigationRequest(
          {required bool isForMainFrame, required String url}) {
        return true;
      }

      navigationDelegate.setOnNavigationRequest(onNavigationRequest);
      expect(params.androidWebViewClient.onNavigationRequestCallback,
          onNavigationRequest);
      expect(params.androidWebViewClient.onLoadUrlCallback, onLoadUrl);
    });

    test('setOnPageStarted should register callback with AndroidWebViewClient',
        () {
      final AndroidNavigationDelegateCreationParams params =
          _buildCreationParams();
      final AndroidNavigationDelegate navigationDelegate =
          AndroidNavigationDelegate.fromNativeApi(
        params,
      );

      void onPageStarted(String url) {}
      navigationDelegate.setOnPageStarted(onPageStarted);
      expect(params.androidWebViewClient.onPageStartedCallback, onPageStarted);
    });

    test('setOnPageFinished should register callback with AndroidWebViewClient',
        () {
      final AndroidNavigationDelegateCreationParams params =
          _buildCreationParams();
      final AndroidNavigationDelegate navigationDelegate =
          AndroidNavigationDelegate.fromNativeApi(
        params,
      );

      void onPageFinished(String url) {}
      navigationDelegate.setOnPageFinished(onPageFinished);
      expect(
          params.androidWebViewClient.onPageFinishedCallback, onPageFinished);
    });

    test('setOnProgress should register callback with AndroidWebChromeClient',
        () {
      final AndroidNavigationDelegateCreationParams params =
          _buildCreationParams();
      final AndroidNavigationDelegate navigationDelegate =
          AndroidNavigationDelegate.fromNativeApi(
        params,
      );

      void onProgress(int progress) {}
      navigationDelegate.setOnProgress(onProgress);
      expect(params.androidWebChromeClient.onProgress, onProgress);
    });

    test(
        'setOnWebResourceError should register callback with AndroidWebViewClient',
        () {
      final AndroidNavigationDelegateCreationParams params =
          _buildCreationParams();
      final AndroidNavigationDelegate navigationDelegate =
          AndroidNavigationDelegate.fromNativeApi(
        params,
      );

      void onWebResourceError(WebResourceError error) {}
      navigationDelegate.setOnWebResourceError(onWebResourceError);
      expect(params.androidWebViewClient.onWebResourceErrorCallback,
          onWebResourceError);
    });
  });

  group('AndroidWebViewClient', () {
    test(
        'handlesNavigation should return true when onNavigationRequestCallback and onLoadUrlCallback are both set',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback =
          ({required bool isForMainFrame, required String url}) => false;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) => Future<void>.value();
      expect(webViewClient.handlesNavigation, isTrue);
    });

    test(
        'handlesNavigation should return flase when onNavigationRequestCallback and onLoadUrlCallback are both not set',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      expect(webViewClient.handlesNavigation, isFalse);
    });

    test(
        'handlesNavigation should return false when onNavigationRequestCallback is not set',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) => Future<void>.value();
      expect(webViewClient.handlesNavigation, isFalse);
    });

    test(
        'handlesNavigation should return false when onLoadUrlCallback is not set',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback =
          ({required bool isForMainFrame, required String url}) => false;
      expect(webViewClient.handlesNavigation, isFalse);
    });

    test('onPageStarted should call callback when set', () async {
      const String urlToReport = 'https://flutter.dev';
      final Completer<String> completer = Completer<String>();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onPageStartedCallback = (String url) {
        completer.complete(url);
      };

      webViewClient.onPageStarted(MockWebView(), urlToReport);
      final String reportedUrl = await completer.future;
      expect(reportedUrl, urlToReport);
    });

    test('onPageStarted should return when no callback is set', () {
      const String urlToReport = 'https://flutter.dev';
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onPageStartedCallback = null;
      webViewClient.onPageStarted(MockWebView(), urlToReport);
    });

    test('onPageFinished should call callback when set', () async {
      const String urlToReport = 'https://flutter.dev';
      final Completer<String> completer = Completer<String>();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onPageFinishedCallback = (String url) {
        completer.complete(url);
      };

      webViewClient.onPageFinished(MockWebView(), urlToReport);
      final String reportedUrl = await completer.future;
      expect(reportedUrl, urlToReport);
    });

    test('onPageFinished should return when no callback is set', () {
      const String urlToReport = 'https://flutter.dev';
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onPageFinishedCallback = null;
      webViewClient.onPageFinished(MockWebView(), urlToReport);
    });

    test('onReceiveError should call callback when set', () async {
      const int errorCode = -14;
      const String errorDescription = 'Page not found';
      const String failingUrl = 'https://flutter.dev';

      final Completer<WebResourceError> completer =
          Completer<WebResourceError>();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onWebResourceErrorCallback = (WebResourceError error) {
        completer.complete(error);
      };

      webViewClient.onReceivedError(
        MockWebView(),
        errorCode,
        errorDescription,
        failingUrl,
      );
      final WebResourceError reportedError = await completer.future;
      expect(reportedError, isInstanceOf<AndroidWebResourceError>());
      expect(reportedError.errorCode, errorCode);
      expect(reportedError.description, errorDescription);
      expect(reportedError.errorType, WebResourceErrorType.fileNotFound);
      expect((reportedError as AndroidWebResourceError).failingUrl, failingUrl);
    });

    test('onReceiveError should return when no callback is set', () {
      const int errorCode = -14;
      const String errorDescription = 'Page not found';
      const String failingUrl = 'https://flutter.dev';
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onWebResourceErrorCallback = null;
      webViewClient.onReceivedError(
        MockWebView(),
        errorCode,
        errorDescription,
        failingUrl,
      );
    });

    test('onReceivedRequestError should call callback when set', () async {
      const String failingUrl = 'https://flutter.dev';
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final android_webview.WebResourceError resourceError =
          android_webview.WebResourceError(
        errorCode: -14,
        description: 'Page not found',
      );

      when(mockRequest.isForMainFrame).thenReturn(true);
      when(mockRequest.url).thenReturn(failingUrl);

      final Completer<WebResourceError> completer =
          Completer<WebResourceError>();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onWebResourceErrorCallback = (WebResourceError error) {
        completer.complete(error);
      };

      webViewClient.onReceivedRequestError(
        MockWebView(),
        mockRequest,
        resourceError,
      );

      final WebResourceError reportedError = await completer.future;
      expect(reportedError, isInstanceOf<AndroidWebResourceError>());
      expect(reportedError.errorCode, resourceError.errorCode);
      expect(reportedError.description, resourceError.description);
      expect(reportedError.errorType, WebResourceErrorType.fileNotFound);
      expect((reportedError as AndroidWebResourceError).failingUrl, failingUrl);
    });

    test(
        'onReceivedRequestError should return when no request.isForMainFrame is false',
        () {
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final android_webview.WebResourceError resourceError =
          android_webview.WebResourceError(
        errorCode: -14,
        description: 'Page not found',
      );
      when(mockRequest.isForMainFrame).thenReturn(false);
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onWebResourceErrorCallback = (WebResourceError error) {
        fail(
            'The `onWebResourceErrorCallback` should not be called when `request.isForMainFrame` is `false`.');
      };
      webViewClient.onReceivedRequestError(
          MockWebView(), mockRequest, resourceError);
    });

    test('onReceivedRequestError should return when no callback is set', () {
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final android_webview.WebResourceError resourceError =
          android_webview.WebResourceError(
        errorCode: -14,
        description: 'Page not found',
      );
      when(mockRequest.isForMainFrame).thenReturn(true);
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onWebResourceErrorCallback = null;
      webViewClient.onReceivedRequestError(
          MockWebView(), mockRequest, resourceError);
    });

    test(
        'urlLoading should call onLoadUrlCallback when onNavigationRequestCallback returns true',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          true;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) async {
        completer.complete();
      };

      webViewClient.urlLoading(MockWebView(), 'https://flutter.dev');
      expect(completer.isCompleted, isTrue);
    });

    test(
        'urlLoading should call onLoadUrlCallback when onNavigationRequestCallback returns a Future true',
        () async {
      final Completer<void> completer = Completer<void>();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          Future<bool>.value(true);
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) async {
        completer.complete();
      };

      webViewClient.urlLoading(MockWebView(), 'https://flutter.dev');
      await completer.future;
      expect(completer.isCompleted, isTrue);
    });

    test(
        'urlLoading should not call onLoadUrlCallback when onNavigationRequestCallback returns false',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          false;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) {
        fail(
            'onLoadUrlCallback should not be called if onNavigationRequestCallback returns false.');
      };

      webViewClient.urlLoading(MockWebView(), 'https://flutter.dev');
    });

    test(
        'urlLoading should not call onLoadUrlCallback when onNavigationRequestCallback returns a Future false',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          Future<bool>.value(false);
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) {
        fail(
            'onLoadUrlCallback should not be called if onNavigationRequestCallback returns false.');
      };

      webViewClient.urlLoading(MockWebView(), 'https://flutter.dev');
    });

    test('urlLoading should return when onNavigationRequestCallback is not set',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = null;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) {
        fail(
            'onLoadUrlCallback should not be called if onNavigationRequestCallback is not set.');
      };

      webViewClient.urlLoading(MockWebView(), 'https://flutter.dev');
    });

    test('urlLoading should return when onLoadUrlCallback is not set', () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) {
        fail(
            'onNavigationRequestCallback should not be called if onLoadUrlCallback is not set.');
      };
      webViewClient.onLoadUrlCallback = null;

      webViewClient.urlLoading(MockWebView(), 'https://flutter.dev');
    });

    test(
        'requestLoading should call onLoadUrlCallback when onNavigationRequestCallback returns true',
        () {
      final Completer<void> completer = Completer<void>();
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      when(mockRequest.isForMainFrame).thenReturn(true);
      when(mockRequest.url).thenReturn('https://flutter.dev');
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          true;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) async {
        expect(url, 'https://flutter.dev');
        completer.complete();
      };

      webViewClient.requestLoading(MockWebView(), mockRequest);
      expect(completer.isCompleted, isTrue);
    });

    test(
        'requestLoading should call onLoadUrlCallback when onNavigationRequestCallback returns a Future true',
        () async {
      final Completer<void> completer = Completer<void>();
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      when(mockRequest.isForMainFrame).thenReturn(true);
      when(mockRequest.url).thenReturn('https://flutter.dev');
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          Future<bool>.value(true);
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) async {
        expect(url, 'https://flutter.dev');
        completer.complete();
      };

      webViewClient.requestLoading(MockWebView(), mockRequest);
      await completer.future;
      expect(completer.isCompleted, isTrue);
    });

    test(
        'requestLoading should not call onLoadUrlCallback when onNavigationRequestCallback returns false',
        () {
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      when(mockRequest.isForMainFrame).thenReturn(true);
      when(mockRequest.url).thenReturn('https://flutter.dev');
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          false;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) {
        fail(
            'onLoadUrlCallback should not be called if onNavigationRequestCallback returns false.');
      };

      webViewClient.requestLoading(MockWebView(), mockRequest);
    });

    test(
        'requestLoading should not call onLoadUrlCallback when onNavigationRequestCallback returns a Future false',
        () {
      final MockWebResourceRequest mockRequest = MockWebResourceRequest();
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      when(mockRequest.isForMainFrame).thenReturn(true);
      when(mockRequest.url).thenReturn('https://flutter.dev');
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) =>
          Future<bool>.value(false);
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) {
        fail(
            'onLoadUrlCallback should not be called if onNavigationRequestCallback returns false.');
      };

      webViewClient.requestLoading(MockWebView(), mockRequest);
    });

    test(
        'requestLoading should return when onNavigationRequestCallback is not set',
        () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = null;
      webViewClient.onLoadUrlCallback =
          (String url, Map<String, String>? headers) {
        fail(
            'onLoadUrlCallback should not be called if onNavigationRequestCallback is not set.');
      };

      webViewClient.requestLoading(MockWebView(), MockWebResourceRequest());
    });

    test('requestLoading should return when onLoadUrlCallback is not set', () {
      final AndroidWebViewClient webViewClient = AndroidWebViewClient();
      webViewClient.onNavigationRequestCallback = ({
        required bool isForMainFrame,
        required String url,
      }) {
        fail(
            'onNavigationRequestCallback should not be called if onLoadUrlCallback is not set.');
      };
      webViewClient.onLoadUrlCallback = null;

      webViewClient.requestLoading(MockWebView(), MockWebResourceRequest());
    });
  });

  group('AndroidWebChromeClient', () {
    test('onProgress should call callback when set', () async {
      const int progressToReport = 42;
      final Completer<int> completer = Completer<int>();
      final AndroidWebChromeClient chromeClient = AndroidWebChromeClient();
      chromeClient.onProgress = (int progress) {
        completer.complete(progress);
      };

      chromeClient.onProgressChanged(MockWebView(), progressToReport);

      final int reportedProgress = await completer.future;
      expect(reportedProgress, progressToReport);
    });

    test('onProgress should return when no callback is set', () {
      const int progressToReport = 42;
      final AndroidWebChromeClient chromeClient = AndroidWebChromeClient();
      chromeClient.onProgressChanged(MockWebView(), progressToReport);
    });
  });
}

Future<void> onLoadUrl(String url, Map<String, String>? headers) async {}

AndroidNavigationDelegateCreationParams _buildCreationParams({
  AndroidWebViewClient? androidWebViewClient,
  AndroidWebChromeClient? androidWebChromeClient,
  Future<void> Function(String url, Map<String, String>? headers)? loadUrl,
}) {
  return AndroidNavigationDelegateCreationParams
      .fromPlatformNavigationDelegateCreationParams(
    const PlatformNavigationDelegateCreationParams(),
    androidWebViewClient: androidWebViewClient ?? AndroidWebViewClient(),
    androidWebChromeClient: androidWebChromeClient ?? AndroidWebChromeClient(),
    loadUrl: loadUrl ?? onLoadUrl,
  );
}
