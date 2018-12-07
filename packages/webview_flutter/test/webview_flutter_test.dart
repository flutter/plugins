// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  final _FakePlatformViewsController fakePlatformViewsController =
      _FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  testWidgets('Create WebView', (WidgetTester tester) async {
    await tester.pumpWidget(const WebView());
  });

  testWidgets('Initial url', (WidgetTester tester) async {
    await tester.pumpWidget(const WebView(
      initialUrl: 'https://youtube.com',
    ));

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.currentUrl, 'https://youtube.com');
  });

  testWidgets('JavaScript mode', (WidgetTester tester) async {
    await tester.pumpWidget(const WebView(
      initialUrl: 'https://youtube.com',
      javaScriptMode: JavaScriptMode.unrestricted,
    ));

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.javaScriptMode, JavaScriptMode.unrestricted);

    await tester.pumpWidget(const WebView(
      initialUrl: 'https://youtube.com',
      javaScriptMode: JavaScriptMode.disabled,
    ));

    expect(platformWebView.javaScriptMode, JavaScriptMode.disabled);
  });

  testWidgets('Load url', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    controller.loadUrl('https://flutter.io');

    expect(platformWebView.currentUrl, 'https://flutter.io');
  });

  testWidgets('Invald urls', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(() => controller.loadUrl(null), throwsA(anything));
    expect(platformWebView.currentUrl, isNull);

    expect(() => controller.loadUrl(''), throwsA(anything));
    expect(platformWebView.currentUrl, isNull);

    // Missing schema.
    expect(() => controller.loadUrl('flutter.io'), throwsA(anything));
    expect(platformWebView.currentUrl, isNull);
  });

  testWidgets("Can't go back before loading a page",
      (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final bool canGoBackNoPageLoaded = await controller.canGoBack();

    expect(canGoBackNoPageLoaded, false);
  });

  testWidgets("Can't go back with no history", (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);
    final bool canGoBackFirstPageLoaded = await controller.canGoBack();

    expect(canGoBackFirstPageLoaded, false);
  });

  testWidgets('Can go back', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    await controller.loadUrl('https://www.google.com');
    final bool canGoBackSecondPageLoaded = await controller.canGoBack();

    expect(canGoBackSecondPageLoaded, true);
  });

  testWidgets("Can't go forward before loading a page",
      (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final bool canGoForwardNoPageLoaded = await controller.canGoForward();

    expect(canGoForwardNoPageLoaded, false);
  });

  testWidgets("Can't go forward with no history", (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);
    final bool canGoForwardFirstPageLoaded = await controller.canGoForward();

    expect(canGoForwardFirstPageLoaded, false);
  });

  testWidgets('Can go forward', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    await controller.loadUrl('https://youtube.com');
    await controller.goBack();
    final bool canGoForwardFirstPageBacked = await controller.canGoForward();

    expect(canGoForwardFirstPageBacked, true);
  });

  testWidgets('Go back', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.currentUrl, 'https://youtube.com');

    controller.loadUrl('https://flutter.io');

    expect(platformWebView.currentUrl, 'https://flutter.io');

    controller.goBack();

    expect(platformWebView.currentUrl, 'https://youtube.com');
  });

  testWidgets('Go forward', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.currentUrl, 'https://youtube.com');

    controller.loadUrl('https://flutter.io');

    expect(platformWebView.currentUrl, 'https://flutter.io');

    controller.goBack();

    expect(platformWebView.currentUrl, 'https://youtube.com');

    controller.goForward();

    expect(platformWebView.currentUrl, 'https://flutter.io');
  });
}

class FakePlatformWebView {
  FakePlatformWebView(int id, Map<dynamic, dynamic> params) {
    if (params.containsKey('initialUrl')) {
      final String initialUrl = params['initialUrl'];
      if (initialUrl != null) {
        history.add(initialUrl);
        currentPosition++;
      }
      javaScriptMode = JavaScriptMode.values[params['settings']['jsMode']];
    }
    channel = MethodChannel(
        'plugins.flutter.io/webview_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel channel;

  List<String> history = <String>[];
  int currentPosition = -1;

  String get currentUrl => history.isEmpty ? null : history[currentPosition];
  JavaScriptMode javaScriptMode;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'loadUrl':
        final String url = call.arguments;
        history = history.sublist(0, currentPosition + 1);
        history.add(url);
        currentPosition++;
        return Future<void>.sync(() {});
      case 'updateSettings':
        if (call.arguments['jsMode'] == null) {
          break;
        }
        javaScriptMode = JavaScriptMode.values[call.arguments['jsMode']];
        break;
      case 'canGoBack':
        return Future<bool>.sync(() => currentPosition > 0);
        break;
      case 'canGoForward':
        return Future<bool>.sync(() => currentPosition < history.length - 1);
        break;
      case 'goBack':
        currentPosition = max(-1, currentPosition - 1);
        return Future<void>.sync(() {});
        break;
      case 'goForward':
        currentPosition = min(history.length - 1, currentPosition + 1);
        return Future<void>.sync(() {});
        break;
    }
    return Future<void>.sync(() {});
  }
}

class _FakePlatformViewsController {
  FakePlatformWebView lastCreatedView;

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        final Map<dynamic, dynamic> args = call.arguments;
        final Map<dynamic, dynamic> params = _decodeParams(args['params']);
        lastCreatedView = FakePlatformWebView(
          args['id'],
          params,
        );
        return Future<int>.sync(() => 1);
      default:
        return Future<void>.sync(() {});
    }
  }

  void reset() {
    lastCreatedView = null;
  }
}

Map<dynamic, dynamic> _decodeParams(Uint8List paramsMessage) {
  final ByteBuffer buffer = paramsMessage.buffer;
  final ByteData messageBytes = buffer.asByteData(
    paramsMessage.offsetInBytes,
    paramsMessage.lengthInBytes,
  );
  return const StandardMessageCodec().decodeMessage(messageBytes);
}
