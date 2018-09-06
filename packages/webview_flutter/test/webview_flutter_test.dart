// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  setUpAll(() {
    SystemChannels.platform_views
        .setMockMethodCallHandler(_fakePlatformViewsMethodHandler);
  });
  testWidgets('Create WebView', (WidgetTester tester) async {
    await tester.pumpWidget(const WebView());
  });

  testWidgets('Load url', (WidgetTester tester) async {
    final int currentViewId = platformViewsRegistry.getNextPlatformViewId();
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
        new FakePlatformWebView(currentViewId + 1);

    controller.loadUrl('https://flutter.io');

    expect(platformWebView.lastUrlLoaded, 'https://flutter.io');
  });

  testWidgets('Invald urls', (WidgetTester tester) async {
    final int currentViewId = platformViewsRegistry.getNextPlatformViewId();
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
        new FakePlatformWebView(currentViewId + 1);

    expect(() => controller.loadUrl(null), throwsA(anything));
    expect(platformWebView.lastUrlLoaded, isNull);

    expect(() => controller.loadUrl(''), throwsA(anything));
    expect(platformWebView.lastUrlLoaded, isNull);

    // Missing schema.
    expect(() => controller.loadUrl('flutter.io'), throwsA(anything));
    expect(platformWebView.lastUrlLoaded, isNull);
  });
}

class FakePlatformWebView {
  FakePlatformWebView(int id) {
    channel = new MethodChannel(
        'plugins.flutter.io/webview_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel channel;

  String lastUrlLoaded;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'loadUrl':
        lastUrlLoaded = call.arguments;
        return new Future<Null>.sync(() => null);
      default:
        return new Future<Null>.sync(() => null);
    }
  }
}

Future<dynamic> _fakePlatformViewsMethodHandler(MethodCall call) {
  switch (call.method) {
    case 'create':
      return Future<int>.sync(() => 1);
    default:
      return new Future<Null>.sync(() => null);
  }
}
