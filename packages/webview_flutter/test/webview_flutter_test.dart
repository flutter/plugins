// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef void VoidCallback();

void main() {
  final _FakePlatformViewsController fakePlatformViewsController =
      _FakePlatformViewsController();

  final _FakeCookieManager _fakeCookieManager = _FakeCookieManager();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
    SystemChannels.platform
        .setMockMethodCallHandler(_fakeCookieManager.onMethodCall);
  });

  setUp(() {
    fakePlatformViewsController.reset();
    _fakeCookieManager.reset();
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

  testWidgets('Headers in loadUrl', (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);

    final Map<String, String> headers = <String, String>{
      'CACHE-CONTROL': 'ABC'
    };
    await controller.loadUrl('https://flutter.io', headers: headers);
    expect(await controller.currentUrl(), equals('https://flutter.io'));
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

  testWidgets("Clear Cache", (WidgetTester tester) async {
    WebViewController controller;
    await tester.pumpWidget(
      WebView(
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );

    expect(controller, isNotNull);
    expect(fakePlatformViewsController.lastCreatedView.hasCache, true);

    await controller.clearCache();

    expect(fakePlatformViewsController.lastCreatedView.hasCache, false);
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

  testWidgets('Cookies can be cleared once', (WidgetTester tester) async {
    await tester.pumpWidget(
      const WebView(
        initialUrl: 'https://flutter.io',
      ),
    );
    final CookieManager cookieManager = CookieManager();
    final bool hasCookies = await cookieManager.clearCookies();
    expect(hasCookies, true);
  });

  testWidgets('Second cookie clear does not have cookies',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const WebView(
        initialUrl: 'https://flutter.io',
      ),
    );
    final CookieManager cookieManager = CookieManager();
    final bool hasCookies = await cookieManager.clearCookies();
    expect(hasCookies, true);
    final bool hasCookiesSecond = await cookieManager.clearCookies();
    expect(hasCookiesSecond, false);
  });

  testWidgets('Initial JavaScript channels', (WidgetTester tester) async {
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Tts', onMessageReceived: (JavascriptMessage msg) {}),
          JavascriptChannel(
              name: 'Alarm', onMessageReceived: (JavascriptMessage msg) {}),
        ].toSet(),
      ),
    );

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.javascriptChannelNames,
        unorderedEquals(<String>['Tts', 'Alarm']));
  });

  test('Only valid JavaScript channel names are allowed', () {
    final JavascriptMessageHandler noOp = (JavascriptMessage msg) {};
    JavascriptChannel(name: 'Tts1', onMessageReceived: noOp);
    JavascriptChannel(name: '_Alarm', onMessageReceived: noOp);

    VoidCallback createChannel(String name) {
      return () {
        JavascriptChannel(name: name, onMessageReceived: noOp);
      };
    }

    expect(createChannel('1Alarm'), throwsAssertionError);
    expect(createChannel('foo.bar'), throwsAssertionError);
    expect(createChannel(''), throwsAssertionError);
  });

  testWidgets('Unique JavaScript channel names are required',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Alarm', onMessageReceived: (JavascriptMessage msg) {}),
          JavascriptChannel(
              name: 'Alarm', onMessageReceived: (JavascriptMessage msg) {}),
        ].toSet(),
      ),
    );
    expect(tester.takeException(), isNot(null));
  });

  testWidgets('JavaScript channels update', (WidgetTester tester) async {
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Tts', onMessageReceived: (JavascriptMessage msg) {}),
          JavascriptChannel(
              name: 'Alarm', onMessageReceived: (JavascriptMessage msg) {}),
        ].toSet(),
      ),
    );

    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Tts', onMessageReceived: (JavascriptMessage msg) {}),
          JavascriptChannel(
              name: 'Alarm2', onMessageReceived: (JavascriptMessage msg) {}),
          JavascriptChannel(
              name: 'Alarm3', onMessageReceived: (JavascriptMessage msg) {}),
        ].toSet(),
      ),
    );

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.javascriptChannelNames,
        unorderedEquals(<String>['Tts', 'Alarm2', 'Alarm3']));
  });

  testWidgets('Remove all JavaScript channels and then add',
      (WidgetTester tester) async {
    // This covers a specific bug we had where after updating javascriptChannels to null,
    // updating it again with a subset of the previously registered channels fails as the
    // widget's cache of current channel wasn't properly updated when updating javascriptChannels to
    // null.
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Tts', onMessageReceived: (JavascriptMessage msg) {}),
        ].toSet(),
      ),
    );

    await tester.pumpWidget(
      const WebView(
        initialUrl: 'https://youtube.com',
      ),
    );

    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Tts', onMessageReceived: (JavascriptMessage msg) {}),
        ].toSet(),
      ),
    );

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(platformWebView.javascriptChannelNames,
        unorderedEquals(<String>['Tts']));
  });

  testWidgets('JavaScript channel messages', (WidgetTester tester) async {
    final List<String> ttsMessagesReceived = <String>[];
    final List<String> alarmMessagesReceived = <String>[];
    await tester.pumpWidget(
      WebView(
        initialUrl: 'https://youtube.com',
        // TODO(iskakaushik): Remove this when collection literals makes it to stable.
        // ignore: prefer_collection_literals
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Tts',
              onMessageReceived: (JavascriptMessage msg) {
                ttsMessagesReceived.add(msg.message);
              }),
          JavascriptChannel(
              name: 'Alarm',
              onMessageReceived: (JavascriptMessage msg) {
                alarmMessagesReceived.add(msg.message);
              }),
        ].toSet(),
      ),
    );

    final FakePlatformWebView platformWebView =
        fakePlatformViewsController.lastCreatedView;

    expect(ttsMessagesReceived, isEmpty);
    expect(alarmMessagesReceived, isEmpty);

    platformWebView.fakeJavascriptPostMessage('Tts', 'Hello');
    platformWebView.fakeJavascriptPostMessage('Tts', 'World');

    expect(ttsMessagesReceived, <String>['Hello', 'World']);
  });

  group('$PageFinishedCallback', () {
    testWidgets('onPageFinished is not null', (WidgetTester tester) async {
      String returnedUrl;

      await tester.pumpWidget(WebView(
        initialUrl: 'https://youtube.com',
        onPageFinished: (String url) {
          returnedUrl = url;
        },
      ));

      final FakePlatformWebView platformWebView =
          fakePlatformViewsController.lastCreatedView;

      platformWebView.fakeOnPageFinishedCallback();

      expect(platformWebView.currentUrl, returnedUrl);
    });

    testWidgets('onPageFinished is null', (WidgetTester tester) async {
      await tester.pumpWidget(const WebView(
        initialUrl: 'https://youtube.com',
        onPageFinished: null,
      ));

      final FakePlatformWebView platformWebView =
          fakePlatformViewsController.lastCreatedView;

      // The platform side will always invoke a call for onPageFinished. This is
      // to test that it does not crash on a null callback.
      platformWebView.fakeOnPageFinishedCallback();
    });

    testWidgets('onPageFinished changed', (WidgetTester tester) async {
      String returnedUrl;

      await tester.pumpWidget(WebView(
        initialUrl: 'https://youtube.com',
        onPageFinished: (String url) {},
      ));

      await tester.pumpWidget(WebView(
        initialUrl: 'https://youtube.com',
        onPageFinished: (String url) {
          returnedUrl = url;
        },
      ));

      final FakePlatformWebView platformWebView =
          fakePlatformViewsController.lastCreatedView;

      platformWebView.fakeOnPageFinishedCallback();

      expect(platformWebView.currentUrl, returnedUrl);
    });
  });

  group('navigationDelegate', () {
    testWidgets('hasNavigationDelegate', (WidgetTester tester) async {
      await tester.pumpWidget(const WebView(
        initialUrl: 'https://youtube.com',
      ));

      final FakePlatformWebView platformWebView =
          fakePlatformViewsController.lastCreatedView;

      expect(platformWebView.hasNavigationDelegate, false);

      await tester.pumpWidget(WebView(
        initialUrl: 'https://youtube.com',
        navigationDelegate: (NavigationRequest r) => null,
      ));

      expect(platformWebView.hasNavigationDelegate, true);
    });

    testWidgets('Block navigation', (WidgetTester tester) async {
      final List<NavigationRequest> navigationRequests = <NavigationRequest>[];

      await tester.pumpWidget(WebView(
          initialUrl: 'https://youtube.com',
          navigationDelegate: (NavigationRequest request) {
            navigationRequests.add(request);
            // Only allow navigating to https://flutter.dev
            return request.url == 'https://flutter.dev'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          }));

      final FakePlatformWebView platformWebView =
          fakePlatformViewsController.lastCreatedView;

      expect(platformWebView.hasNavigationDelegate, true);

      platformWebView.fakeNavigate('https://www.google.com');
      // The navigation delegate only allows navigation to https://flutter.dev
      // so we should still be in https://youtube.com.
      expect(platformWebView.currentUrl, 'https://youtube.com');
      expect(navigationRequests.length, 1);
      expect(navigationRequests[0].url, 'https://www.google.com');
      expect(navigationRequests[0].isForMainFrame, true);

      platformWebView.fakeNavigate('https://flutter.dev');
      await tester.pump();
      expect(platformWebView.currentUrl, 'https://flutter.dev');
    });
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
    }
    if (params.containsKey('javascriptChannelNames')) {
      javascriptChannelNames =
          List<String>.from(params['javascriptChannelNames']);
    }
    javascriptMode = JavascriptMode.values[params['settings']['jsMode']];
    hasNavigationDelegate =
        params['settings']['hasNavigationDelegate'] ?? false;
    channel = MethodChannel(
        'plugins.flutter.io/webview_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel channel;

  List<String> history = <String>[];
  int currentPosition = -1;
  int amountOfReloadsOnCurrentUrl = 0;
  bool hasCache = true;

  String get currentUrl => history.isEmpty ? null : history[currentPosition];
  JavascriptMode javascriptMode;
  List<String> javascriptChannelNames;

  bool hasNavigationDelegate;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'loadUrl':
        final Map<dynamic, dynamic> request = call.arguments;
        _loadUrl(request['url']);
        return Future<void>.sync(() {});
      case 'updateSettings':
        if (call.arguments['jsMode'] != null) {
          javascriptMode = JavascriptMode.values[call.arguments['jsMode']];
        }
        if (call.arguments['hasNavigationDelegate'] != null) {
          hasNavigationDelegate = call.arguments['hasNavigationDelegate'];
        }
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
        break;
      case 'addJavascriptChannels':
        final List<String> channelNames = List<String>.from(call.arguments);
        javascriptChannelNames.addAll(channelNames);
        break;
      case 'removeJavascriptChannels':
        final List<String> channelNames = List<String>.from(call.arguments);
        javascriptChannelNames
            .removeWhere((String channel) => channelNames.contains(channel));
        break;
      case 'clearCache':
        hasCache = false;
        return Future<void>.sync(() {});
    }
    return Future<void>.sync(() {});
  }

  void fakeJavascriptPostMessage(String jsChannel, String message) {
    final StandardMethodCodec codec = const StandardMethodCodec();
    final Map<String, dynamic> arguments = <String, dynamic>{
      'channel': jsChannel,
      'message': message
    };
    final ByteData data = codec
        .encodeMethodCall(MethodCall('javascriptChannelMessage', arguments));
    BinaryMessages.handlePlatformMessage(
        channel.name, data, (ByteData data) {});
  }

  // Fakes a main frame navigation that was initiated by the webview, e.g when
  // the user clicks a link in the currently loaded page.
  void fakeNavigate(String url) {
    if (!hasNavigationDelegate) {
      print('no navigation delegate');
      _loadUrl(url);
      return;
    }
    final StandardMethodCodec codec = const StandardMethodCodec();
    final Map<String, dynamic> arguments = <String, dynamic>{
      'url': url,
      'isForMainFrame': true
    };
    final ByteData data =
        codec.encodeMethodCall(MethodCall('navigationRequest', arguments));
    BinaryMessages.handlePlatformMessage(channel.name, data, (ByteData data) {
      final bool allow = codec.decodeEnvelope(data);
      if (allow) {
        _loadUrl(url);
      }
    });
  }

  void fakeOnPageFinishedCallback() {
    final StandardMethodCodec codec = const StandardMethodCodec();

    final ByteData data = codec.encodeMethodCall(MethodCall(
      'onPageFinished',
      <dynamic, dynamic>{'url': currentUrl},
    ));

    BinaryMessages.handlePlatformMessage(
      channel.name,
      data,
      (ByteData data) {},
    );
  }

  void _loadUrl(String url) {
    history = history.sublist(0, currentPosition + 1);
    history.add(url);
    currentPosition++;
    amountOfReloadsOnCurrentUrl = 0;
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

class _FakeCookieManager {
  _FakeCookieManager() {
    final MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/cookie_manager',
      StandardMethodCodec(),
    );
    channel.setMockMethodCallHandler(onMethodCall);
  }

  bool hasCookies = true;

  Future<bool> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'clearCookies':
        bool hadCookies = false;
        if (hasCookies) {
          hadCookies = true;
          hasCookies = false;
        }
        return Future<bool>.sync(() {
          return hadCookies;
        });
        break;
    }
    return Future<bool>.sync(() {});
  }

  void reset() {
    hasCookies = true;
  }
}
