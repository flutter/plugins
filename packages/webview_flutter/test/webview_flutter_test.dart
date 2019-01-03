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
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(await controller.currentUrl(), 'https://youtube.com');
  });

  testWidgets('Javascript mode', (WidgetTester tester) async {
    await tester.pumpWidget(const WebView(
      initialUrl: 'https://youtube.com',
      javascriptMode: JavascriptMode.unrestricted,
    ));

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.javascriptMode, JavascriptMode.unrestricted);

    await tester.pumpWidget(const WebView(
      initialUrl: 'https://youtube.com',
      javascriptMode: JavascriptMode.disabled,
    ));

    expect(platformWebView.javascriptMode, JavascriptMode.disabled);
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

    controller.loadUrl('https://flutter.io');

    expect(await controller.currentUrl(), 'https://flutter.io');
  });

  testWidgets('Invalid urls', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    expect(() => controller.loadUrl(null), throwsA(anything));
    expect(await controller.currentUrl(), isNull);

    expect(() => controller.loadUrl(''), throwsA(anything));
    expect(await controller.currentUrl(), isNull);

    // Missing schema.
    expect(() => controller.loadUrl('flutter.io'), throwsA(anything));
    expect(await controller.currentUrl(), isNull);
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

    expect(await controller.currentUrl(), 'https://youtube.com');

    controller.loadUrl('https://flutter.io');

    expect(await controller.currentUrl(), 'https://flutter.io');

    controller.goBack();

    expect(await controller.currentUrl(), 'https://youtube.com');
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

    expect(await controller.currentUrl(), 'https://youtube.com');

    controller.loadUrl('https://flutter.io');

    expect(await controller.currentUrl(), 'https://flutter.io');

    controller.goBack();

    expect(await controller.currentUrl(), 'https://youtube.com');

    controller.goForward();

    expect(await controller.currentUrl(), 'https://flutter.io');
  });

  testWidgets('Current URL', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    // Test a WebView without an explicitly set first URL.
    expect(await controller.currentUrl(), isNull);

    controller.loadUrl('https://youtube.com');
    expect(await controller.currentUrl(), 'https://youtube.com');

    controller.loadUrl('https://flutter.io');
    expect(await controller.currentUrl(), 'https://flutter.io');

    controller.goBack();
    expect(await controller.currentUrl(), 'https://youtube.com');
  });

  testWidgets('Reload url', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.currentUrl, 'https://flutter.io');
    expect(platformWebView.amountOfReloadsOnCurrentUrl, 0);

    controller.reload();

    expect(platformWebView.currentUrl, 'https://flutter.io');
    expect(platformWebView.amountOfReloadsOnCurrentUrl, 1);

    controller.loadUrl('https://youtube.com');

    expect(platformWebView.amountOfReloadsOnCurrentUrl, 0);
  });

  testWidgets('evaluate Javascript', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );
    expect(
        await controller.evaluateJavascript("fake js string"), "fake js string",
        reason: 'should get the argument');
    expect(
      () => controller.evaluateJavascript(null),
      throwsA(anything),
    );
  });

  testWidgets('evaluate Javascript with JavascriptMode disabled',
      (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://flutter.io',
        javascriptMode: JavascriptMode.disabled,
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );
    expect(
      () => controller.evaluateJavascript('fake js string'),
      throwsA(anything),
    );
    expect(
      () => controller.evaluateJavascript(null),
      throwsA(anything),
    );
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
      javascriptMode = JavascriptMode.values[params['settings']['jsMode']];
    }
    channel = MethodChannel(
        'plugins.flutter.io/webview_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel channel;

  List<String> history = <String>[];
  int currentPosition = -1;
  int amountOfReloadsOnCurrentUrl = 0;

  String get currentUrl => history.isEmpty ? null : history[currentPosition];
  JavascriptMode javascriptMode;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'loadUrl':
        final String url = call.arguments;
        history = history.sublist(0, currentPosition + 1);
        history.add(url);
        currentPosition++;
        amountOfReloadsOnCurrentUrl = 0;
        return Future<void>.sync(() {});
      case 'updateSettings':
        if (call.arguments['jsMode'] == null) {
          break;
        }
        javascriptMode = JavascriptMode.values[call.arguments['jsMode']];
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
      case 'reload':
        amountOfReloadsOnCurrentUrl++;
        return Future<void>.sync(() {});
        break;
      case 'currentUrl':
        return Future<String>.value(currentUrl);
        break;
      case 'evaluateJavascript':
        return Future<dynamic>.value(call.arguments);
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
