// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:webview_flutter_platform_interface/src/method_channel/webview_method_channel.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tests on `plugin.flutter.io/webview_<channel_id>` channel', () {
    const int channelId = 1;
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/webview_$channelId');
    final WebViewPlatformCallbacksHandler callbacksHandler =
        MockWebViewPlatformCallbacksHandler();
    final JavascriptChannelRegistry javascriptChannelRegistry =
        MockJavascriptChannelRegistry();

    final List<MethodCall> log = <MethodCall>[];
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);

      switch (methodCall.method) {
        case 'currentUrl':
          return 'https://test.url';
        case 'canGoBack':
        case 'canGoForward':
          return true;
        case 'evaluateJavascript':
          return methodCall.arguments as String;
        case 'getScrollX':
          return 10;
        case 'getScrollY':
          return 20;
      }

      // Return null explicitly instead of relying on the implicit null
      // returned by the method channel if no return statement is specified.
      return null;
    });

    final MethodChannelWebViewPlatform webViewPlatform =
        MethodChannelWebViewPlatform(
      channelId,
      callbacksHandler,
      javascriptChannelRegistry,
    );

    tearDown(() {
      log.clear();
    });

    test('loadUrl with headers', () async {
      await webViewPlatform.loadUrl(
        'https://test.url',
        const <String, String>{
          'Content-Type': 'text/plain',
          'Accept': 'text/html',
        },
      );

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'loadUrl',
            arguments: <String, dynamic>{
              'url': 'https://test.url',
              'headers': <String, String>{
                'Content-Type': 'text/plain',
                'Accept': 'text/html',
              },
            },
          ),
        ],
      );
    });

    test('loadUrl without headers', () async {
      await webViewPlatform.loadUrl(
        'https://test.url',
        null,
      );

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'loadUrl',
            arguments: <String, dynamic>{
              'url': 'https://test.url',
              'headers': null,
            },
          ),
        ],
      );
    });

    test('currentUrl', () async {
      final String? currentUrl = await webViewPlatform.currentUrl();

      expect(currentUrl, 'https://test.url');
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUrl',
            arguments: null,
          ),
        ],
      );
    });

    test('canGoBack', () async {
      final bool canGoBack = await webViewPlatform.canGoBack();

      expect(canGoBack, true);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'canGoBack',
            arguments: null,
          ),
        ],
      );
    });

    test('canGoForward', () async {
      final bool canGoForward = await webViewPlatform.canGoForward();

      expect(canGoForward, true);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'canGoForward',
            arguments: null,
          ),
        ],
      );
    });

    test('goBack', () async {
      await webViewPlatform.goBack();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'goBack',
            arguments: null,
          ),
        ],
      );
    });

    test('goForward', () async {
      await webViewPlatform.goForward();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'goForward',
            arguments: null,
          ),
        ],
      );
    });

    test('reload', () async {
      await webViewPlatform.reload();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reload',
            arguments: null,
          ),
        ],
      );
    });

    test('clearCache', () async {
      await webViewPlatform.clearCache();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'clearCache',
            arguments: null,
          ),
        ],
      );
    });

    test('updateSettings', () async {
      final WebSettings settings =
          WebSettings(userAgent: WebSetting<String?>.of('Dart Test'));
      await webViewPlatform.updateSettings(settings);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'updateSettings',
            arguments: <String, dynamic>{
              'userAgent': 'Dart Test',
            },
          ),
        ],
      );
    });

    test('updateSettings all parameters', () async {
      final WebSettings settings = WebSettings(
        userAgent: WebSetting<String?>.of('Dart Test'),
        javascriptMode: JavascriptMode.disabled,
        hasNavigationDelegate: true,
        hasProgressTracking: true,
        debuggingEnabled: true,
        gestureNavigationEnabled: true,
        allowsInlineMediaPlayback: true,
      );
      await webViewPlatform.updateSettings(settings);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'updateSettings',
            arguments: <String, dynamic>{
              'userAgent': 'Dart Test',
              'jsMode': 0,
              'hasNavigationDelegate': true,
              'hasProgressTracking': true,
              'debuggingEnabled': true,
              'gestureNavigationEnabled': true,
              'allowsInlineMediaPlayback': true,
            },
          ),
        ],
      );
    });

    test('updateSettings without settings', () async {
      final WebSettings settings =
          WebSettings(userAgent: WebSetting<String?>.absent());
      await webViewPlatform.updateSettings(settings);

      expect(
        log.isEmpty,
        true,
      );
    });

    test('evaluateJavascript', () async {
      final String evaluateJavascript =
          await webViewPlatform.evaluateJavascript(
        'This simulates some Javascript code.',
      );

      expect('This simulates some Javascript code.', evaluateJavascript);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'evaluateJavascript',
            arguments: 'This simulates some Javascript code.',
          ),
        ],
      );
    });

    test('addJavascriptChannels', () async {
      final Set<String> channels = <String>{'channel one', 'channel two'};
      await webViewPlatform.addJavascriptChannels(channels);

      expect(log, <Matcher>[
        isMethodCall(
          'addJavascriptChannels',
          arguments: <String>[
            'channel one',
            'channel two',
          ],
        ),
      ]);
    });

    test('addJavascriptChannels without channels', () async {
      final Set<String> channels = <String>{};
      await webViewPlatform.addJavascriptChannels(channels);

      expect(log, <Matcher>[
        isMethodCall(
          'addJavascriptChannels',
          arguments: <String>[],
        ),
      ]);
    });

    test('removeJavascriptChannels', () async {
      final Set<String> channels = <String>{'channel one', 'channel two'};
      await webViewPlatform.removeJavascriptChannels(channels);

      expect(log, <Matcher>[
        isMethodCall(
          'removeJavascriptChannels',
          arguments: <String>[
            'channel one',
            'channel two',
          ],
        ),
      ]);
    });

    test('removeJavascriptChannels without channels', () async {
      final Set<String> channels = <String>{};
      await webViewPlatform.removeJavascriptChannels(channels);

      expect(log, <Matcher>[
        isMethodCall(
          'removeJavascriptChannels',
          arguments: <String>[],
        ),
      ]);
    });

    test('getTitle', () async {
      final String? title = await webViewPlatform.getTitle();

      expect(title, null);
      expect(
        log,
        <Matcher>[
          isMethodCall('getTitle', arguments: null),
        ],
      );
    });

    test('scrollTo', () async {
      await webViewPlatform.scrollTo(10, 20);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'scrollTo',
            arguments: <String, int>{
              'x': 10,
              'y': 20,
            },
          ),
        ],
      );
    });

    test('scrollBy', () async {
      await webViewPlatform.scrollBy(10, 20);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'scrollBy',
            arguments: <String, int>{
              'x': 10,
              'y': 20,
            },
          ),
        ],
      );
    });

    test('getScrollX', () async {
      final int x = await webViewPlatform.getScrollX();

      expect(x, 10);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'getScrollX',
            arguments: null,
          ),
        ],
      );
    });

    test('getScrollY', () async {
      final int y = await webViewPlatform.getScrollY();

      expect(y, 20);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'getScrollY',
            arguments: null,
          ),
        ],
      );
    });
  });

  group('Tests on `plugins.flutter.io/cookie_manager` channel', () {
    const MethodChannel cookieChannel =
        MethodChannel('plugins.flutter.io/cookie_manager');

    final List<MethodCall> log = <MethodCall>[];
    cookieChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);

      if (methodCall.method == 'clearCookies') {
        return true;
      }

      // Return null explicitly instead of relying on the implicit null
      // returned by the method channel if no return statement is specified.
      return null;
    });

    tearDown(() {
      log.clear();
    });

    test('clearCookies', () async {
      final bool clearCookies =
          await MethodChannelWebViewPlatform.clearCookies();

      expect(clearCookies, true);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'clearCookies',
            arguments: null,
          ),
        ],
      );
    });
  });
}

class MockWebViewPlatformCallbacksHandler extends Mock
    implements WebViewPlatformCallbacksHandler {}

class MockJavascriptChannelRegistry extends Mock
    implements JavascriptChannelRegistry {}
