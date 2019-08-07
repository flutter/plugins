// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);
  tearDownAll(() => allTestsCompleter.complete(null));

  test('initalUrl', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final String currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter.dev/');
  });

  test('loadUrl', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await controller.loadUrl('https://www.google.com/');
    final String currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://www.google.com/');
  });

  // enable this once https://github.com/flutter/flutter/issues/31510
  // is resolved.
  test('loadUrl with headers', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final StreamController<String> pageLoads = StreamController<String>();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            pageLoads.add(url);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final Map<String, String> headers = <String, String>{
      'test_header': 'flutter_test_header'
    };
    await controller.loadUrl('https://flutter-header-echo.herokuapp.com/',
        headers: headers);
    final String currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter-header-echo.herokuapp.com/');

    await pageLoads.stream.firstWhere((String url) => url == currentUrl);
    final String content = await controller
        .evaluateJavascript('document.documentElement.innerText');
    expect(content.contains('flutter_test_header'), isTrue);
  });

  test('JavaScriptChannel', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final List<String> messagesReceived = <String>[];
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          // This is the data URL for: '<!DOCTYPE html>'
          initialUrl:
              'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          javascriptMode: JavascriptMode.unrestricted,
          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            JavascriptChannel(
              name: 'Echo',
              onMessageReceived: (JavascriptMessage message) {
                messagesReceived.add(message.message);
              },
            ),
          ].toSet(),
          onPageFinished: (String url) {
            pageLoaded.complete(null);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    expect(messagesReceived, isEmpty);
    await controller.evaluateJavascript('Echo.postMessage("hello");');
    expect(messagesReceived, equals(<String>['hello']));
  });

  group('Media playback policy', () {
    String audioTestBase64;
    setUpAll(() async {
      final ByteData audioData =
          await rootBundle.load('assets/sample_audio.ogg');
      final String base64AudioData =
          base64Encode(Uint8List.view(audioData.buffer));
      final String audioTest = '''
        <!DOCTYPE html><html>
        <head><title>Audio auto play</title>
          <script type="text/javascript">
            function play() {
              var audio = document.getElementById("audio");
              audio.play();
            }
            function isPaused() {
              var audio = document.getElementById("audio");
              return audio.paused;
            }
          </script>
        </head>
        <body onload="play();">
        <audio controls id="audio">
          <source src="data:audio/ogg;charset=utf-8;base64,$base64AudioData">
        </audio>
        </body>
        </html>
      ''';
      audioTestBase64 = base64Encode(const Utf8Encoder().convert(audioTest));
    });

    test('Auto media playback', () async {
      Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();

      await pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          ),
        ),
      );
      WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      String isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(false));

      controllerCompleter = Completer<WebViewController>();
      pageLoaded = Completer<void>();

      // We change the key to re-create a new webview as we change the initialMediaPlaybackPolicy
      await pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
        ),
      );

      controller = await controllerCompleter.future;
      await pageLoaded.future;

      isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(true));
    });

    test('Changes to initialMediaPlaybackPolocy are ignored', () async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();

      final GlobalKey key = GlobalKey();
      await pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: key,
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          ),
        ),
      );
      final WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      String isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(false));

      pageLoaded = Completer<void>();

      await pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: key,
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
        ),
      );

      await controller.reload();

      await pageLoaded.future;

      isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(false));
    });
  });
}

Future<void> pumpWidget(Widget widget) {
  runApp(widget);
  return WidgetsBinding.instance.endOfFrame;
}

// JavaScript booleans evaluate to different string values on Android and iOS.
// This utility method returns the string boolean value of the current platform.
String _webviewBool(bool value) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return value ? '1' : '0';
  }
  return value ? 'true' : 'false';
}
