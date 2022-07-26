// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/v4/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/src/v4/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('WebKitNavigationDelegate', () {
    WKNavigationDelegate Function({
      void Function(WKWebView webView, String? url)? didFinishNavigation,
      void Function(WKWebView webView, String? url)?
          didStartProvisionalNavigation,
      Future<WKNavigationActionPolicy> Function(
        WKWebView webView,
        WKNavigationAction navigationAction,
      )?
          decidePolicyForNavigationAction,
      void Function(WKWebView webView, NSError error)? didFailNavigation,
      void Function(WKWebView webView, NSError error)?
          didFailProvisionalNavigation,
      void Function(WKWebView webView)? webViewWebContentProcessDidTerminate,
    }) createDetachedDelegate(
      void Function(WKNavigationDelegate delegate) onCreateDelegate,
    ) {
      return ({
        void Function(WKWebView webView, String? url)? didFinishNavigation,
        void Function(WKWebView webView, String? url)?
            didStartProvisionalNavigation,
        Future<WKNavigationActionPolicy> Function(
          WKWebView webView,
          WKNavigationAction navigationAction,
        )?
            decidePolicyForNavigationAction,
        void Function(WKWebView webView, NSError error)? didFailNavigation,
        void Function(WKWebView webView, NSError error)?
            didFailProvisionalNavigation,
        void Function(WKWebView webView)? webViewWebContentProcessDidTerminate,
      }) {
        final WKNavigationDelegate delegate = WKNavigationDelegate.detached(
          didFinishNavigation: didFinishNavigation,
          didStartProvisionalNavigation: didStartProvisionalNavigation,
          decidePolicyForNavigationAction: decidePolicyForNavigationAction,
          didFailNavigation: didFailNavigation,
          didFailProvisionalNavigation: didFailProvisionalNavigation,
          webViewWebContentProcessDidTerminate:
              webViewWebContentProcessDidTerminate,
        );
        onCreateDelegate(delegate);
        return delegate;
      };
    }

    test('setOnPageFinished', () async {
      late final WKNavigationDelegate navigationDelegate;

      final WebKitProxy webKitProxy = WebKitProxy(
        createNavigationDelegate: createDetachedDelegate(
          (WKNavigationDelegate delegate) => navigationDelegate = delegate,
        ),
      );

      late final String callbackUrl;
      void onPageFinished(String url) => callbackUrl = url;

      final WebKitNavigationDelegate webKitDelgate = WebKitNavigationDelegate(
        const PlatformNavigationDelegateCreationParams(),
        webKitProxy: webKitProxy,
      );
      webKitDelgate.setOnPageFinished(onPageFinished);
      navigationDelegate.didFinishNavigation!(
        WKWebView.detached(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnPageStarted', () async {
      late final WKNavigationDelegate navigationDelegate;

      final WebKitProxy webKitProxy = WebKitProxy(
        createNavigationDelegate: createDetachedDelegate(
          (WKNavigationDelegate delegate) => navigationDelegate = delegate,
        ),
      );

      late final String callbackUrl;
      void onPageStarted(String url) => callbackUrl = url;

      final WebKitNavigationDelegate webKitDelgate = WebKitNavigationDelegate(
        const PlatformNavigationDelegateCreationParams(),
        webKitProxy: webKitProxy,
      );
      webKitDelgate.setOnPageStarted(onPageStarted);
      navigationDelegate.didStartProvisionalNavigation!(
        WKWebView.detached(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onWebResourceError from didFailNavigation', () async {
      late final WKNavigationDelegate navigationDelegate;

      final WebKitProxy webKitProxy = WebKitProxy(
        createNavigationDelegate: createDetachedDelegate(
          (WKNavigationDelegate delegate) => navigationDelegate = delegate,
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      final WebKitNavigationDelegate webKitDelgate = WebKitNavigationDelegate(
        const PlatformNavigationDelegateCreationParams(),
        webKitProxy: webKitProxy,
      );
      webKitDelgate.setOnWebResourceError(onWebResourceError);
      navigationDelegate.didFailNavigation!(
        WKWebView.detached(),
        const NSError(
          code: WKErrorCode.webViewInvalidated,
          domain: 'domain',
          localizedDescription: 'my desc',
        ),
      );

      expect(callbackError.description, 'my desc');
      expect(callbackError.errorCode, WKErrorCode.webViewInvalidated);
      expect(callbackError.domain, 'domain');
      expect(callbackError.errorType, WebResourceErrorType.webViewInvalidated);
    });

    test('onWebResourceError from didFailProvisionalNavigation', () async {
      late final WKNavigationDelegate navigationDelegate;

      final WebKitProxy webKitProxy = WebKitProxy(
        createNavigationDelegate: createDetachedDelegate(
          (WKNavigationDelegate delegate) => navigationDelegate = delegate,
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      final WebKitNavigationDelegate webKitDelgate = WebKitNavigationDelegate(
        const PlatformNavigationDelegateCreationParams(),
        webKitProxy: webKitProxy,
      );
      webKitDelgate.setOnWebResourceError(onWebResourceError);
      navigationDelegate.didFailProvisionalNavigation!(
        WKWebView.detached(),
        const NSError(
          code: WKErrorCode.webViewInvalidated,
          domain: 'domain',
          localizedDescription: 'my desc',
        ),
      );

      expect(callbackError.description, 'my desc');
      expect(callbackError.errorCode, WKErrorCode.webViewInvalidated);
      expect(callbackError.domain, 'domain');
      expect(callbackError.errorType, WebResourceErrorType.webViewInvalidated);
    });

    test('onWebResourceError from webViewWebContentProcessDidTerminate',
        () async {
      late final WKNavigationDelegate navigationDelegate;

      final WebKitProxy webKitProxy = WebKitProxy(
        createNavigationDelegate: createDetachedDelegate(
          (WKNavigationDelegate delegate) => navigationDelegate = delegate,
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      final WebKitNavigationDelegate webKitDelgate = WebKitNavigationDelegate(
        const PlatformNavigationDelegateCreationParams(),
        webKitProxy: webKitProxy,
      );
      webKitDelgate.setOnWebResourceError(onWebResourceError);
      navigationDelegate.webViewWebContentProcessDidTerminate!(
        WKWebView.detached(),
      );

      expect(callbackError.description, '');
      expect(callbackError.errorCode, WKErrorCode.webContentProcessTerminated);
      expect(callbackError.domain, 'WKErrorDomain');
      expect(
        callbackError.errorType,
        WebResourceErrorType.webContentProcessTerminated,
      );
    });

    test('onNavigationRequest from decidePolicyForNavigationAction', () async {
      late final WKNavigationDelegate navigationDelegate;

      final WebKitProxy webKitProxy = WebKitProxy(
        createNavigationDelegate: createDetachedDelegate(
          (WKNavigationDelegate delegate) => navigationDelegate = delegate,
        ),
      );

      late final String callbackUrl;
      late final bool callbackIsMainFrame;
      FutureOr<bool> onNavigationRequest({
        required String url,
        required bool isForMainFrame,
      }) {
        callbackUrl = url;
        callbackIsMainFrame = isForMainFrame;
        return true;
      }

      final WebKitNavigationDelegate webKitDelgate = WebKitNavigationDelegate(
        const PlatformNavigationDelegateCreationParams(),
        webKitProxy: webKitProxy,
      );
      webKitDelgate.setOnNavigationRequest(onNavigationRequest);

      expect(
        navigationDelegate.decidePolicyForNavigationAction!(
          WKWebView.detached(),
          const WKNavigationAction(
            request: NSUrlRequest(url: 'https://www.google.com'),
            targetFrame: WKFrameInfo(isMainFrame: false),
          ),
        ),
        completion(WKNavigationActionPolicy.allow),
      );

      expect(callbackUrl, 'https://www.google.com');
      expect(callbackIsMainFrame, isFalse);
    });
  });
}
