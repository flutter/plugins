// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_android/src/android_proxy.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  group('AndroidNavigationDelegate', () {
    test('onPageFinished', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final String callbackUrl;
      androidNavigationDelegate
          .setOnPageFinished((String url) => callbackUrl = url);

      CapturingWebViewClient.lastCreatedDelegate.onPageFinished!(
        android_webview.WebView.detached(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onPageStarted', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final String callbackUrl;
      androidNavigationDelegate
          .setOnPageStarted((String url) => callbackUrl = url);

      CapturingWebViewClient.lastCreatedDelegate.onPageStarted!(
        android_webview.WebView.detached(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onWebResourceError from onReceivedRequestError', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final WebResourceError callbackError;
      androidNavigationDelegate.setOnWebResourceError(
          (WebResourceError error) => callbackError = error);

      CapturingWebViewClient.lastCreatedDelegate.onReceivedRequestError!(
        android_webview.WebView.detached(),
        android_webview.WebResourceRequest(
          url: 'https://www.google.com',
          isForMainFrame: false,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: <String, String>{'X-Mock': 'mocking'},
        ),
        android_webview.WebResourceError(
          errorCode: android_webview.WebViewClient.errorFileNotFound,
          description: 'Page not found.',
        ),
      );

      expect(callbackError.errorCode,
          android_webview.WebViewClient.errorFileNotFound);
      expect(callbackError.description, 'Page not found.');
      expect(callbackError.errorType, WebResourceErrorType.fileNotFound);
      expect(callbackError.isForMainFrame, false);
    });

    test('onWebResourceError from onRequestError', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final WebResourceError callbackError;
      androidNavigationDelegate.setOnWebResourceError(
          (WebResourceError error) => callbackError = error);

      CapturingWebViewClient.lastCreatedDelegate.onReceivedError!(
        android_webview.WebView.detached(),
        android_webview.WebViewClient.errorFileNotFound,
        'Page not found.',
        'https://www.google.com',
      );

      expect(callbackError.errorCode,
          android_webview.WebViewClient.errorFileNotFound);
      expect(callbackError.description, 'Page not found.');
      expect(callbackError.errorType, WebResourceErrorType.fileNotFound);
      expect(callbackError.isForMainFrame, true);
    });

    test(
        'onNavigationRequest from requestLoading should not be called when loadUrlCallback is not specified',
        () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      NavigationRequest? callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        android_webview.WebView.detached(),
        android_webview.WebResourceRequest(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: <String, String>{'X-Mock': 'mocking'},
        ),
      );

      expect(callbackNavigationRequest, isNull);
    });

    test(
        'onLoadRequest from requestLoading should not be called when navigationRequestCallback is not specified',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        android_webview.WebView.detached(),
        android_webview.WebResourceRequest(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: <String, String>{'X-Mock': 'mocking'},
        ),
      );

      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from requestLoading should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        android_webview.WebView.detached(),
        android_webview.WebResourceRequest(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: <String, String>{'X-Mock': 'mocking'},
        ),
      );

      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from requestLoading should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
        () {
      final Completer<void> completer = Completer<void>();
      late final LoadRequestParams loadRequestParams;
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
        loadRequestParams = params;
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.navigate;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        android_webview.WebView.detached(),
        android_webview.WebResourceRequest(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: <String, String>{'X-Mock': 'mocking'},
        ),
      );

      expect(loadRequestParams.uri.toString(), 'https://www.google.com');
      expect(loadRequestParams.headers, <String, String>{'X-Mock': 'mocking'});
      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, true);
    });

    test(
        'onNavigationRequest from urlLoading should not be called when loadUrlCallback is not specified',
        () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      NavigationRequest? callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        android_webview.WebView.detached(),
        'https://www.google.com',
      );

      expect(callbackNavigationRequest, isNull);
    });

    test(
        'onLoadRequest from urlLoading should not be called when navigationRequestCallback is not specified',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        android_webview.WebView.detached(),
        'https://www.google.com',
      );

      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from urlLoading should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        android_webview.WebView.detached(),
        'https://www.google.com',
      );

      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from urlLoading should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
        () {
      final Completer<void> completer = Completer<void>();
      late final LoadRequestParams loadRequestParams;
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
        loadRequestParams = params;
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.navigate;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        android_webview.WebView.detached(),
        'https://www.google.com',
      );

      expect(loadRequestParams.uri.toString(), 'https://www.google.com');
      expect(loadRequestParams.headers, <String, String>{});
      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, true);
    });

    test('setOnNavigationRequest should override URL loading', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnNavigationRequest(
        (NavigationRequest request) => NavigationDecision.navigate,
      );

      expect(
          CapturingWebViewClient.lastCreatedDelegate
              .synchronousReturnValueForShouldOverrideUrlLoading,
          isTrue);
    });

    test('onProgress', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final int callbackProgress;
      androidNavigationDelegate
          .setOnProgress((int progress) => callbackProgress = progress);

      CapturingWebChromeClient.lastCreatedDelegate.onProgressChanged!(
        android_webview.WebView.detached(),
        42,
      );

      expect(callbackProgress, 42);
    });

    test(
        'onLoadRequest from onDownloadStart should not be called when navigationRequestCallback is not specified',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      CapturingDownloadListener.lastCreatedListener.onDownloadStart(
        '',
        '',
        '',
        '',
        0,
      );

      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from onDownloadStart should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingDownloadListener.lastCreatedListener.onDownloadStart(
        'https://www.google.com',
        '',
        '',
        '',
        0,
      );

      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from onDownloadStart should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
        () {
      final Completer<void> completer = Completer<void>();
      late final LoadRequestParams loadRequestParams;
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
        loadRequestParams = params;
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.navigate;
      });

      CapturingDownloadListener.lastCreatedListener.onDownloadStart(
        'https://www.google.com',
        '',
        '',
        '',
        0,
      );

      expect(loadRequestParams.uri.toString(), 'https://www.google.com');
      expect(loadRequestParams.headers, <String, String>{});
      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, true);
    });
  });
}

AndroidNavigationDelegateCreationParams _buildCreationParams() {
  return AndroidNavigationDelegateCreationParams
      .fromPlatformNavigationDelegateCreationParams(
    const PlatformNavigationDelegateCreationParams(),
    androidWebViewProxy: const AndroidWebViewProxy(
      createAndroidWebChromeClient: CapturingWebChromeClient.new,
      createAndroidWebViewClient: CapturingWebViewClient.new,
      createDownloadListener: CapturingDownloadListener.new,
    ),
  );
}

// Records the last created instance of itself.
class CapturingWebViewClient extends android_webview.WebViewClient {
  CapturingWebViewClient({
    super.onPageFinished,
    super.onPageStarted,
    super.onReceivedError,
    super.onReceivedRequestError,
    super.requestLoading,
    super.urlLoading,
  }) : super.detached() {
    lastCreatedDelegate = this;
  }

  static CapturingWebViewClient lastCreatedDelegate = CapturingWebViewClient();

  bool synchronousReturnValueForShouldOverrideUrlLoading = false;

  @override
  Future<void> setSynchronousReturnValueForShouldOverrideUrlLoading(
      bool value) async {
    synchronousReturnValueForShouldOverrideUrlLoading = value;
  }
}

// Records the last created instance of itself.
class CapturingWebChromeClient extends android_webview.WebChromeClient {
  CapturingWebChromeClient({
    super.onProgressChanged,
  }) : super.detached() {
    lastCreatedDelegate = this;
  }
  static CapturingWebChromeClient lastCreatedDelegate =
      CapturingWebChromeClient();
}

// Records the last created instance of itself.
class CapturingDownloadListener extends android_webview.DownloadListener {
  CapturingDownloadListener({
    required super.onDownloadStart,
  }) : super.detached() {
    lastCreatedListener = this;
  }
  static CapturingDownloadListener lastCreatedListener =
      CapturingDownloadListener(onDownloadStart: (_, __, ___, ____, _____) {});
}
