// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/src/v4/src/android_navigation_delegate.dart';
import 'package:webview_flutter_android/src/v4/src/android_proxy.dart';
import 'package:webview_flutter_android/src/v4/src/android_webview_controller.dart';
import 'package:webview_flutter_platform_interface/v4/src/webview_platform.dart';

import 'android_webview_controller_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<AndroidNavigationDelegate>(),
  MockSpec<AndroidWebViewProxy>(),
  MockSpec<android_webview.FlutterAssetManager>(),
  MockSpec<android_webview.JavaScriptChannel>(),
  MockSpec<android_webview.WebChromeClient>(),
  MockSpec<android_webview.WebSettings>(),
  MockSpec<android_webview.WebView>(),
  MockSpec<android_webview.WebViewClient>(),
  MockSpec<android_webview.WebStorage>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidWebViewController', () {
    AndroidWebViewController createControllerWithMocks({
      android_webview.FlutterAssetManager? mockFlutterAssetManager,
      android_webview.JavaScriptChannel? mockJavaScriptChannel,
      android_webview.WebChromeClient? mockWebChromeClient,
      android_webview.WebView? mockWebView,
      android_webview.WebViewClient? mockWebViewClient,
      android_webview.WebStorage? mockWebStorage,
    }) {
      final android_webview.WebView nonNullMockWebView =
          mockWebView ?? MockWebView();

      final AndroidWebViewControllerCreationParams creationParams =
          AndroidWebViewControllerCreationParams(
              androidWebStorage: mockWebStorage ?? MockWebStorage(),
              androidWebViewProxy: AndroidWebViewProxy(
                createAndroidWebChromeClient: (
                        {void Function(android_webview.WebView, int)?
                            onProgressChanged}) =>
                    mockWebChromeClient ?? MockWebChromeClient(),
                createAndroidWebView: ({required bool useHybridComposition}) =>
                    nonNullMockWebView,
                createAndroidWebViewClient: ({
                  void Function(android_webview.WebView webView, String url)?
                      onPageFinished,
                  void Function(android_webview.WebView webView, String url)?
                      onPageStarted,
                  @Deprecated('Only called on Android version < 23.')
                      void Function(
                    android_webview.WebView webView,
                    int errorCode,
                    String description,
                    String failingUrl,
                  )?
                          onReceivedError,
                  void Function(
                    android_webview.WebView webView,
                    android_webview.WebResourceRequest request,
                    android_webview.WebResourceError error,
                  )?
                      onReceivedRequestError,
                  void Function(
                    android_webview.WebView webView,
                    android_webview.WebResourceRequest request,
                  )?
                      requestLoading,
                  void Function(android_webview.WebView webView, String url)?
                      urlLoading,
                }) =>
                    mockWebViewClient ?? MockWebViewClient(),
                createFlutterAssetManager: () =>
                    mockFlutterAssetManager ?? MockFlutterAssetManager(),
                createJavaScriptChannel: (
                  String channelName, {
                  required void Function(String) postMessage,
                }) =>
                    mockJavaScriptChannel ?? MockJavaScriptChannel(),
              ));

      return AndroidWebViewController(creationParams);
    }

    AndroidJavaScriptChannelParams
        createAndroidJavaScriptChannelParamsWithMocks({
      String? name,
      MockJavaScriptChannel? mockJavaScriptChannel,
    }) {
      return AndroidJavaScriptChannelParams(
          name: name ?? 'test',
          onMessageReceived: (JavaScriptMessage message) {},
          webViewProxy: AndroidWebViewProxy(
            createJavaScriptChannel: (
              String channelName, {
              required void Function(String) postMessage,
            }) =>
                mockJavaScriptChannel ?? MockJavaScriptChannel(),
          ));
    }

    test('loadFile without file prefix', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockWebSettings);

      await controller.loadFile('/path/to/file.html');

      verify(mockWebSettings.setAllowFileAccess(true)).called(1);
      verify(mockWebView.loadUrl(
        'file:///path/to/file.html',
        <String, String>{},
      )).called(1);
    });

    test('loadFile without file prefix and characters to be escaped', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockWebSettings);

      await controller.loadFile('/path/to/?_<_>_.html');

      verify(mockWebSettings.setAllowFileAccess(true)).called(1);
      verify(mockWebView.loadUrl(
        'file:///path/to/%3F_%3C_%3E_.html',
        <String, String>{},
      )).called(1);
    });

    test('loadFile with file prefix', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockWebSettings);

      await controller.loadFile('file:///path/to/file.html');

      verify(mockWebSettings.setAllowFileAccess(true)).called(1);
      verify(mockWebView.loadUrl(
        'file:///path/to/file.html',
        <String, String>{},
      )).called(1);
    });

    test('loadFlutterAsset when asset does not exists', () async {
      final MockWebView mockWebView = MockWebView();
      final MockFlutterAssetManager mockAssetManager =
          MockFlutterAssetManager();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockFlutterAssetManager: mockAssetManager,
        mockWebView: mockWebView,
      );

      when(mockAssetManager.getAssetFilePathByName('mock_key'))
          .thenAnswer((_) => Future<String>.value(''));
      when(mockAssetManager.list(''))
          .thenAnswer((_) => Future<List<String>>.value(<String>[]));

      try {
        await controller.loadFlutterAsset('mock_key');
        fail('Expected an `ArgumentError`.');
      } on ArgumentError catch (e) {
        expect(e.message, 'Asset for key "mock_key" not found.');
        expect(e.name, 'key');
      } on Error {
        fail('Expect an `ArgumentError`.');
      }

      verify(mockAssetManager.getAssetFilePathByName('mock_key')).called(1);
      verify(mockAssetManager.list('')).called(1);
      verifyNever(mockWebView.loadUrl(any, any));
    });

    test('loadFlutterAsset when asset does exists', () async {
      final MockWebView mockWebView = MockWebView();
      final MockFlutterAssetManager mockAssetManager =
          MockFlutterAssetManager();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockFlutterAssetManager: mockAssetManager,
        mockWebView: mockWebView,
      );

      when(mockAssetManager.getAssetFilePathByName('mock_key'))
          .thenAnswer((_) => Future<String>.value('www/mock_file.html'));
      when(mockAssetManager.list('www')).thenAnswer(
          (_) => Future<List<String>>.value(<String>['mock_file.html']));

      await controller.loadFlutterAsset('mock_key');

      verify(mockAssetManager.getAssetFilePathByName('mock_key')).called(1);
      verify(mockAssetManager.list('www')).called(1);
      verify(mockWebView.loadUrl(
          'file:///android_asset/www/mock_file.html', <String, String>{}));
    });

    test(
        'loadFlutterAsset when asset name contains characters that should be escaped',
        () async {
      final MockWebView mockWebView = MockWebView();
      final MockFlutterAssetManager mockAssetManager =
          MockFlutterAssetManager();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockFlutterAssetManager: mockAssetManager,
        mockWebView: mockWebView,
      );

      when(mockAssetManager.getAssetFilePathByName('mock_key'))
          .thenAnswer((_) => Future<String>.value('www/?_<_>_.html'));
      when(mockAssetManager.list('www')).thenAnswer(
          (_) => Future<List<String>>.value(<String>['?_<_>_.html']));

      await controller.loadFlutterAsset('mock_key');

      verify(mockAssetManager.getAssetFilePathByName('mock_key')).called(1);
      verify(mockAssetManager.list('www')).called(1);
      verify(mockWebView.loadUrl(
          'file:///android_asset/www/%3F_%3C_%3E_.html', <String, String>{}));
    });

    test('loadHtmlString without baseUrl', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.loadHtmlString('<p>Hello Test!</p>');

      verify(mockWebView.loadDataWithBaseUrl(
        data: '<p>Hello Test!</p>',
        mimeType: 'text/html',
      )).called(1);
    });

    test('loadHtmlString with baseUrl', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.loadHtmlString('<p>Hello Test!</p>',
          baseUrl: 'https://flutter.dev');

      verify(mockWebView.loadDataWithBaseUrl(
        data: '<p>Hello Test!</p>',
        baseUrl: 'https://flutter.dev',
        mimeType: 'text/html',
      )).called(1);
    });

    test('loadRequest without URI scheme', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('flutter.dev'),
        method: LoadRequestMethod.get,
        headers: const <String, String>{},
      );

      try {
        await controller.loadRequest(requestParams);
        fail('Expect an `ArgumentError`.');
      } on ArgumentError catch (e) {
        expect(e.message, 'WebViewRequest#uri is required to have a scheme.');
      } on Error {
        fail('Expect a `ArgumentError`.');
      }

      verifyNever(mockWebView.loadUrl(any, any));
      verifyNever(mockWebView.postUrl(any, any));
    });

    test('loadRequest using the GET method', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
        method: LoadRequestMethod.get,
        headers: const <String, String>{'X-Test': 'Testing'},
      );

      await controller.loadRequest(requestParams);

      verify(mockWebView.loadUrl(
        'https://flutter.dev',
        <String, String>{'X-Test': 'Testing'},
      ));
      verifyNever(mockWebView.postUrl(any, any));
    });

    test('loadRequest using the POST method without body', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
        method: LoadRequestMethod.post,
        headers: const <String, String>{'X-Test': 'Testing'},
      );

      await controller.loadRequest(requestParams);

      verify(mockWebView.postUrl(
        'https://flutter.dev',
        Uint8List(0),
      ));
      verifyNever(mockWebView.loadUrl(any, any));
    });

    test('loadRequest using the POST method with body', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
        method: LoadRequestMethod.post,
        headers: const <String, String>{'X-Test': 'Testing'},
        body: Uint8List.fromList('{"message": "Hello World!"}'.codeUnits),
      );

      await controller.loadRequest(requestParams);

      verify(mockWebView.postUrl(
        'https://flutter.dev',
        Uint8List.fromList('{"message": "Hello World!"}'.codeUnits),
      ));
      verifyNever(mockWebView.loadUrl(any, any));
    });

    test('currentUrl', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.currentUrl();

      verify(mockWebView.getUrl()).called(1);
    });

    test('canGoBack', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.canGoBack();

      verify(mockWebView.canGoBack()).called(1);
    });

    test('canGoForward', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.canGoForward();

      verify(mockWebView.canGoForward()).called(1);
    });

    test('goBack', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.goBack();

      verify(mockWebView.goBack()).called(1);
    });

    test('goForward', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.goForward();

      verify(mockWebView.goForward()).called(1);
    });

    test('reload', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.reload();

      verify(mockWebView.reload()).called(1);
    });

    test('clearCache', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.clearCache();

      verify(mockWebView.clearCache(true)).called(1);
    });

    test('clearLocalStorage', () async {
      final MockWebStorage mockWebStorage = MockWebStorage();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebStorage: mockWebStorage,
      );

      await controller.clearLocalStorage();

      verify(mockWebStorage.deleteAllData()).called(1);
    });

    test('setPlatformNavigationDelegate', () async {
      final MockAndroidNavigationDelegate mockNavigationDelegate =
          MockAndroidNavigationDelegate();
      final MockWebView mockWebView = MockWebView();
      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final MockWebViewClient mockWebViewClient = MockWebViewClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockNavigationDelegate.androidWebChromeClient)
          .thenReturn(mockWebChromeClient);
      when(mockNavigationDelegate.androidWebViewClient)
          .thenReturn(mockWebViewClient);

      await controller.setPlatformNavigationDelegate(mockNavigationDelegate);

      verifyInOrder(<Object>[
        mockWebView.setWebViewClient(mockWebViewClient),
        mockWebView.setWebChromeClient(mockWebChromeClient),
      ]);
    });

    test('runJavaScript', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.runJavaScript('alert("This is a test.");');

      verify(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .called(1);
    });

    test('runJavaScriptReturningResult with return value', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('return "Hello" + " World!";'))
          .thenAnswer((_) => Future<String>.value('Hello World!'));

      final String message = await controller
          .runJavaScriptReturningResult('return "Hello" + " World!";');

      expect(message, 'Hello World!');
    });

    test('runJavaScriptReturningResult returning null', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .thenAnswer((_) => Future<String?>.value());

      final String message = await controller
          .runJavaScriptReturningResult('alert("This is a test.");');

      expect(message, '');
    });

    test('addJavaScriptChannel', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final AndroidJavaScriptChannelParams paramsWithMock =
          createAndroidJavaScriptChannelParamsWithMocks(name: 'test');
      await controller.addJavaScriptChannel(paramsWithMock);
      verify(mockWebView.addJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);
    });

    test(
        'addJavaScriptChannel add channel with same name should remove existing channel',
        () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final AndroidJavaScriptChannelParams paramsWithMock =
          createAndroidJavaScriptChannelParamsWithMocks(name: 'test');
      await controller.addJavaScriptChannel(paramsWithMock);
      verify(mockWebView.addJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);

      await controller.addJavaScriptChannel(paramsWithMock);
      verifyInOrder(<Object>[
        mockWebView.removeJavaScriptChannel(
            argThat(isA<android_webview.JavaScriptChannel>())),
        mockWebView.addJavaScriptChannel(
            argThat(isA<android_webview.JavaScriptChannel>())),
      ]);
    });

    test('removeJavaScriptChannel when channel is not registered', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.removeJavaScriptChannel('test');
      verifyNever(mockWebView.removeJavaScriptChannel(any));
    });

    test('removeJavaScriptChannel when channel exists', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final AndroidJavaScriptChannelParams paramsWithMock =
          createAndroidJavaScriptChannelParamsWithMocks(name: 'test');

      // Make sure channel exists before removing it.
      await controller.addJavaScriptChannel(paramsWithMock);
      verify(mockWebView.addJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);

      await controller.removeJavaScriptChannel('test');
      verify(mockWebView.removeJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);
    });

    test('getTitle', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.getTitle();

      verify(mockWebView.getTitle()).called(1);
    });

    test('scrollTo', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.scrollTo(4, 2);

      verify(mockWebView.scrollTo(4, 2)).called(1);
    });

    test('scrollBy', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.scrollBy(4, 2);

      verify(mockWebView.scrollBy(4, 2)).called(1);
    });

    test('getScrollPosition', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      when(mockWebView.getScrollPosition())
          .thenAnswer((_) => Future<Offset>.value(const Offset(4, 2)));

      final Point<int> position = await controller.getScrollPosition();

      verify(mockWebView.getScrollPosition()).called(1);
      expect(position.x, 4);
      expect(position.y, 2);
    });

    test('enableDebugging', () async {
      final MockAndroidWebViewProxy mockProxy = MockAndroidWebViewProxy();
      final AndroidWebViewControllerCreationParams creationParams =
          AndroidWebViewControllerCreationParams(
        androidWebViewProxy: mockProxy,
        androidWebStorage: MockWebStorage(),
      );
      final AndroidWebViewController controller =
          AndroidWebViewController(creationParams);

      await controller.enableDebugging(true);

      verify(mockProxy.setWebContentsDebuggingEnabled(true)).called(1);
    });

    test('enableDomStorage', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.enableDomStorage(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setDomStorageEnabled(true)).called(1);
    });

    test('enableFileAccess', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.enableFileAccess(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setAllowFileAccess(true)).called(1);
    });

    test('enableZoom', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.enableZoom(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setSupportZoom(true)).called(1);
    });

    test('setBackgroundColor', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.setBackgroundColor(Colors.blue);

      verify(mockWebView.setBackgroundColor(Colors.blue)).called(1);
    });

    test('setBuiltInZoomControls', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setBuiltInZoomControls(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setBuiltInZoomControls(true)).called(1);
    });

    test('setDisplayZoomControls', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setDisplayZoomControls(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setDisplayZoomControls(true)).called(1);
    });

    test('setJavaScriptCanOpenWindowsAutomatically', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setJavaScriptCanOpenWindowsAutomatically(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setJavaScriptCanOpenWindowsAutomatically(true))
          .called(1);
    });

    test('setJavaScriptMode', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setJavaScriptMode(JavaScriptMode.disabled);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setJavaScriptEnabled(false)).called(1);
    });

    test(
        'setAutoMediaPlaybackPolicy should set Media Playback Requires User Gesture to false when policy is set to always_allow.',
        () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller
          .setAutoMediaPlaybackPolicy(AutoMediaPlaybackPolicy.always_allow);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setMediaPlaybackRequiresUserGesture(false)).called(1);
    });

    test(
        'setAutoMediaPlaybackPolicy should set Media Playback Requires User Gesture to true when policy is anything but always_allow.',
        () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setAutoMediaPlaybackPolicy(
          AutoMediaPlaybackPolicy.require_user_action_for_all_media_types);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setMediaPlaybackRequiresUserGesture(true)).called(1);
    });

    test('setLoadWithOverviewMode', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setLoadWithOverviewMode(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setLoadWithOverviewMode(true)).called(1);
    });

    test('setSupportMultipleWindows', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setSupportMultipleWindows(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setSupportMultipleWindows(true)).called(1);
    });

    test('setUserAgent', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setUserAgent('Test Framework');

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setUserAgentString('Test Framework')).called(1);
    });

    test('setUseWideViewPort', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockSettings);

      await controller.setUseWideViewPort(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setUseWideViewPort(true)).called(1);
    });
  });
}
