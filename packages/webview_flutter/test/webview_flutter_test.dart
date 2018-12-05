// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

    expect(platformWebView.lastUrlLoaded, 'https://youtube.com');
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

    expect(platformWebView.lastUrlLoaded, 'https://flutter.io');
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
    expect(platformWebView.lastUrlLoaded, isNull);

    expect(() => controller.loadUrl(''), throwsA(anything));
    expect(platformWebView.lastUrlLoaded, isNull);

    // Missing schema.
    expect(() => controller.loadUrl('flutter.io'), throwsA(anything));
    expect(platformWebView.lastUrlLoaded, isNull);
  });

  testWidgets('Check can go back', (WidgetTester tester) async {
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

    await controller.loadUrl('https://flutter.io');
    final canGoBack = await controller.canGoBack;

    expect(canGoBack, false);
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

    expect(platformWebView.lastUrlLoaded, 'https://youtube.com');

    controller.loadUrl('https://flutter.io');

    expect(platformWebView.lastUrlLoaded, 'https://flutter.io');
  });
}

class FakePlatformWebView {
  FakePlatformWebView(int id, Map<dynamic, dynamic> params) {
    if (params.containsKey('initialUrl')) {
      final String initialUrl = params['initialUrl'];
      if (initialUrl != null) {
        history.add(initialUrl);
      }
      javaScriptMode = JavaScriptMode.values[params['settings']['jsMode']];
    }
    channel = MethodChannel(
        'plugins.flutter.io/webview_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel channel;

  List<String> history = <String>[];
  String get lastUrlLoaded => (history.isEmpty) ? null : history.last;
  JavaScriptMode javaScriptMode;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'loadUrl':
        history.add(call.arguments);
        return Future<void>.sync(() {});
      case 'updateSettings':
        if (call.arguments['jsMode'] == null) {
          break;
        }
        javaScriptMode = JavaScriptMode.values[call.arguments['jsMode']];
        break;
      case 'canGoBack':
        return Future<bool>.sync(() => history.length > 1);
        break;
      case 'goBack':
        history.removeLast();
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
