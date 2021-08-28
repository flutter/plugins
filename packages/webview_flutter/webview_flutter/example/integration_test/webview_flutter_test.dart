// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
  testWidgets('initialUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
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
    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter.dev/');
  }, skip: true);

  // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
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
    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://www.google.com/');
  }, skip: true);

  // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
  testWidgets('loadUrl with headers', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final StreamController<String> pageStarts = StreamController<String>();
    final StreamController<String> pageLoads = StreamController<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          javascriptMode: JavascriptMode.unrestricted,
          onPageStarted: (String url) {
            pageStarts.add(url);
          },
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
    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter-header-echo.herokuapp.com/');

    await pageStarts.stream.firstWhere((String url) => url == currentUrl);
    await pageLoads.stream.firstWhere((String url) => url == currentUrl);

    final String content = await controller
        .evaluateJavascript('document.documentElement.innerText');
    expect(content.contains('flutter_test_header'), isTrue);
  }, skip: Platform.isAndroid);

  // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
  testWidgets('JavaScriptChannel', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final Completer<void> pageStarted = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();
    final List<String> messagesReceived = <String>[];
    await tester.pumpWidget(
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
          javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
              name: 'Echo',
              onMessageReceived: (JavascriptMessage message) {
                messagesReceived.add(message.message);
              },
            ),
          },
          onPageStarted: (String url) {
            pageStarted.complete(null);
          },
          onPageFinished: (String url) {
            pageLoaded.complete(null);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await pageStarted.future;
    await pageLoaded.future;

    expect(messagesReceived, isEmpty);
    // Append a return value "1" in the end will prevent an iOS platform exception.
    // See: https://github.com/flutter/flutter/issues/66318#issuecomment-701105380
    // TODO(cyanglaz): remove the workaround "1" in the end when the below issue is fixed.
    // https://github.com/flutter/flutter/issues/66318
    await controller.evaluateJavascript('Echo.postMessage("hello");1;');
    expect(messagesReceived, equals(<String>['hello']));
  }, skip: Platform.isAndroid);

  testWidgets('resize webview', (WidgetTester tester) async {
    final String resizeTest = '''
        <!DOCTYPE html><html>
        <head><title>Resize test</title>
          <script type="text/javascript">
            function onResize() {
              Resize.postMessage("resize");
            }
            function onLoad() {
              window.onresize = onResize;
            }
          </script>
        </head>
        <body onload="onLoad();" bgColor="blue">
        </body>
        </html>
      ''';
    final String resizeTestBase64 =
        base64Encode(const Utf8Encoder().convert(resizeTest));
    final Completer<void> resizeCompleter = Completer<void>();
    final Completer<void> pageStarted = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final GlobalKey key = GlobalKey();

    final WebView webView = WebView(
      key: key,
      initialUrl: 'data:text/html;charset=utf-8;base64,$resizeTestBase64',
      onWebViewCreated: (WebViewController controller) {
        controllerCompleter.complete(controller);
      },
      javascriptChannels: <JavascriptChannel>{
        JavascriptChannel(
          name: 'Resize',
          onMessageReceived: (JavascriptMessage message) {
            resizeCompleter.complete(true);
          },
        ),
      },
      onPageStarted: (String url) {
        pageStarted.complete(null);
      },
      onPageFinished: (String url) {
        pageLoaded.complete(null);
      },
      javascriptMode: JavascriptMode.unrestricted,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 200,
              child: webView,
            ),
          ],
        ),
      ),
    );

    await controllerCompleter.future;
    await pageStarted.future;
    await pageLoaded.future;

    expect(resizeCompleter.isCompleted, false);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 400,
              height: 400,
              child: webView,
            ),
          ],
        ),
      ),
    );

    await resizeCompleter.future;
  });

  testWidgets('set custom userAgent', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter1 =
        Completer<WebViewController>();
    final GlobalKey _globalKey = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: 'Custom_User_Agent1',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter1.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller1 = await controllerCompleter1.future;
    final String customUserAgent1 = await _getUserAgent(controller1);
    expect(customUserAgent1, 'Custom_User_Agent1');
    // rebuild the WebView with a different user agent.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: 'Custom_User_Agent2',
        ),
      ),
    );

    final String customUserAgent2 = await _getUserAgent(controller1);
    expect(customUserAgent2, 'Custom_User_Agent2');
  });

  // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
  testWidgets('use default platform userAgent after webView is rebuilt',
      (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final GlobalKey _globalKey = GlobalKey();
    // Build the webView with no user agent to get the default platform user agent.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'https://flutter.dev/',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final String defaultPlatformUserAgent = await _getUserAgent(controller);
    // rebuild the WebView with a custom user agent.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: 'Custom_User_Agent',
        ),
      ),
    );
    final String customUserAgent = await _getUserAgent(controller);
    expect(customUserAgent, 'Custom_User_Agent');
    // rebuilds the WebView with no user agent.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );

    final String customUserAgent2 = await _getUserAgent(controller);
    expect(customUserAgent2, defaultPlatformUserAgent);
  }, skip: Platform.isAndroid);

  group('Video playback policy', () {
    late String videoTestBase64;
    setUpAll(() async {
      final ByteData videoData =
          await rootBundle.load('assets/sample_video.mp4');
      final String base64VideoData =
          base64Encode(Uint8List.view(videoData.buffer));
      final String videoTest = '''
        <!DOCTYPE html><html>
        <head><title>Video auto play</title>
          <script type="text/javascript">
            function play() {
              var video = document.getElementById("video");
              video.play();
              video.addEventListener('timeupdate', videoTimeUpdateHandler, false);
            }
            function videoTimeUpdateHandler(e) {
              var video = document.getElementById("video");
              VideoTestTime.postMessage(video.currentTime);
            }
            function isPaused() {
              var video = document.getElementById("video");
              return video.paused;
            }
            function isFullScreen() {
              var video = document.getElementById("video");
              return video.webkitDisplayingFullscreen;
            }
          </script>
        </head>
        <body onload="play();">
        <video controls playsinline autoplay id="video">
          <source src="data:video/mp4;charset=utf-8;base64,$base64VideoData">
        </video>
        </body>
        </html>
      ''';
      videoTestBase64 = base64Encode(const Utf8Encoder().convert(videoTest));
    });

    testWidgets('Auto media playback', (WidgetTester tester) async {
      Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
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
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
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

    testWidgets('Changes to initialMediaPlaybackPolicy are ignored',
        (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();

      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: key,
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
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

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: key,
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
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

    testWidgets('Video plays inline when allowsInlineMediaPlayback is true',
        (WidgetTester tester) async {
      Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();
      Completer<void> videoPlaying = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>{
              JavascriptChannel(
                name: 'VideoTestTime',
                onMessageReceived: (JavascriptMessage message) {
                  final double currentTime = double.parse(message.message);
                  // Let it play for at least 1 second to make sure the related video's properties are set.
                  if (currentTime > 1) {
                    videoPlaying.complete(null);
                  }
                },
              ),
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            allowsInlineMediaPlayback: true,
          ),
        ),
      );
      WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      // Pump once to trigger the video play.
      await tester.pump();

      // Makes sure we get the correct event that indicates the video is actually playing.
      await videoPlaying.future;

      String fullScreen =
          await controller.evaluateJavascript('isFullScreen();');
      expect(fullScreen, _webviewBool(false));
    });

    // allowsInlineMediaPlayback is a noop on Android, so it is skipped.
    testWidgets(
        'Video plays full screen when allowsInlineMediaPlayback is false',
        (WidgetTester tester) async {
      Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();
      Completer<void> videoPlaying = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>{
              JavascriptChannel(
                name: 'VideoTestTime',
                onMessageReceived: (JavascriptMessage message) {
                  final double currentTime = double.parse(message.message);
                  // Let it play for at least 1 second to make sure the related video's properties are set.
                  if (currentTime > 1) {
                    videoPlaying.complete(null);
                  }
                },
              ),
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            allowsInlineMediaPlayback: false,
          ),
        ),
      );
      WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      // Pump once to trigger the video play.
      await tester.pump();

      // Makes sure we get the correct event that indicates the video is actually playing.
      await videoPlaying.future;

      String fullScreen =
          await controller.evaluateJavascript('isFullScreen();');
      expect(fullScreen, _webviewBool(true));
    }, skip: Platform.isAndroid);
  });

  group('Audio playback policy', () {
    late String audioTestBase64;
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

    testWidgets('Auto media playback', (WidgetTester tester) async {
      Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageStarted = Completer<void>();
      Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (String url) {
              pageStarted.complete(null);
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          ),
        ),
      );
      WebViewController controller = await controllerCompleter.future;
      await pageStarted.future;
      await pageLoaded.future;

      String isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(false));

      controllerCompleter = Completer<WebViewController>();
      pageStarted = Completer<void>();
      pageLoaded = Completer<void>();

      // We change the key to re-create a new webview as we change the initialMediaPlaybackPolicy
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (String url) {
              pageStarted.complete(null);
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
        ),
      );

      controller = await controllerCompleter.future;
      await pageStarted.future;
      await pageLoaded.future;

      isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(true));
    });

    testWidgets('Changes to initialMediaPlaybackPolocy are ignored',
        (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageStarted = Completer<void>();
      Completer<void> pageLoaded = Completer<void>();

      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: key,
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (String url) {
              pageStarted.complete(null);
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          ),
        ),
      );
      final WebViewController controller = await controllerCompleter.future;
      await pageStarted.future;
      await pageLoaded.future;

      String isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(false));

      pageStarted = Completer<void>();
      pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: key,
            initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (String url) {
              pageStarted.complete(null);
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
            initialMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
        ),
      );

      await controller.reload();

      await pageStarted.future;
      await pageLoaded.future;

      isPaused = await controller.evaluateJavascript('isPaused();');
      expect(isPaused, _webviewBool(false));
    });
  });

  testWidgets('getTitle', (WidgetTester tester) async {
    final String getTitleTest = '''
        <!DOCTYPE html><html>
        <head><title>Some title</title>
        </head>
        <body>
        </body>
        </html>
      ''';
    final String getTitleTestBase64 =
        base64Encode(const Utf8Encoder().convert(getTitleTest));
    final Completer<void> pageStarted = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          initialUrl: 'data:text/html;charset=utf-8;base64,$getTitleTestBase64',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          onPageStarted: (String url) {
            pageStarted.complete(null);
          },
          onPageFinished: (String url) {
            pageLoaded.complete(null);
          },
        ),
      ),
    );

    final WebViewController controller = await controllerCompleter.future;
    await pageStarted.future;
    await pageLoaded.future;

    final String? title = await controller.getTitle();
    expect(title, 'Some title');
  });

  group('Programmatic Scroll', () {
    // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
    testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
      final String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

      final String scrollTestPageBase64 =
          base64Encode(const Utf8Encoder().convert(scrollTestPage));

      final Completer<void> pageLoaded = Completer<void>();
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            initialUrl:
                'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
          ),
        ),
      );

      final WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      await tester.pumpAndSettle(Duration(seconds: 3));

      int scrollPosX = await controller.getScrollX();
      int scrollPosY = await controller.getScrollY();

      // Check scrollTo()
      const int X_SCROLL = 123;
      const int Y_SCROLL = 321;
      // Get the initial position; this ensures that scrollTo is actually
      // changing something, but also gives the native view's scroll position
      // time to settle.
      expect(scrollPosX, isNot(X_SCROLL));
      expect(scrollPosX, isNot(Y_SCROLL));

      await controller.scrollTo(X_SCROLL, Y_SCROLL);
      scrollPosX = await controller.getScrollX();
      scrollPosY = await controller.getScrollY();
      expect(scrollPosX, X_SCROLL);
      expect(scrollPosY, Y_SCROLL);

      // Check scrollBy() (on top of scrollTo())
      await controller.scrollBy(X_SCROLL, Y_SCROLL);
      scrollPosX = await controller.getScrollX();
      scrollPosY = await controller.getScrollY();
      expect(scrollPosX, X_SCROLL * 2);
      expect(scrollPosY, Y_SCROLL * 2);
    }, skip: Platform.isAndroid);
  });

  group('SurfaceAndroidWebView', () {
    setUpAll(() {
      WebView.platform = SurfaceAndroidWebView();
    });

    tearDownAll(() {
      WebView.platform = null;
    });

    // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
    testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
      final String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

      final String scrollTestPageBase64 =
          base64Encode(const Utf8Encoder().convert(scrollTestPage));

      final Completer<void> pageLoaded = Completer<void>();
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            initialUrl:
                'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            onPageFinished: (String url) {
              pageLoaded.complete(null);
            },
          ),
        ),
      );

      final WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      await tester.pumpAndSettle(Duration(seconds: 3));

      // Check scrollTo()
      const int X_SCROLL = 123;
      const int Y_SCROLL = 321;

      await controller.scrollTo(X_SCROLL, Y_SCROLL);
      int scrollPosX = await controller.getScrollX();
      int scrollPosY = await controller.getScrollY();
      expect(X_SCROLL, scrollPosX);
      expect(Y_SCROLL, scrollPosY);

      // Check scrollBy() (on top of scrollTo())
      await controller.scrollBy(X_SCROLL, Y_SCROLL);
      scrollPosX = await controller.getScrollX();
      scrollPosY = await controller.getScrollY();
      expect(X_SCROLL * 2, scrollPosX);
      expect(Y_SCROLL * 2, scrollPosY);
    }, skip: true);

    // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
    testWidgets('inputs are scrolled into view when focused',
        (WidgetTester tester) async {
      final String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              input {
                margin: 10000px 0;
              }
              #viewport {
                position: fixed;
                top:0;
                bottom:0;
                left:0;
                right:0;
              }
            </style>
          </head>
          <body>
            <div id="viewport"></div>
            <input type="text" id="inputEl">
          </body>
        </html>
      ''';

      final String scrollTestPageBase64 =
          base64Encode(const Utf8Encoder().convert(scrollTestPage));

      final Completer<void> pageLoaded = Completer<void>();
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();

      await tester.runAsync(() async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 200,
              child: WebView(
                initialUrl:
                    'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
                onWebViewCreated: (WebViewController controller) {
                  controllerCompleter.complete(controller);
                },
                onPageFinished: (String url) {
                  pageLoaded.complete(null);
                },
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
          ),
        );
        await Future.delayed(Duration(milliseconds: 20));
        await tester.pump();
      });

      final WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;
      final String viewportRectJSON = await _evaluateJavascript(
          controller, 'JSON.stringify(viewport.getBoundingClientRect())');
      final Map<String, dynamic> viewportRectRelativeToViewport =
          jsonDecode(viewportRectJSON);

      // Check that the input is originally outside of the viewport.

      final String initialInputClientRectJSON = await _evaluateJavascript(
          controller, 'JSON.stringify(inputEl.getBoundingClientRect())');
      final Map<String, dynamic> initialInputClientRectRelativeToViewport =
          jsonDecode(initialInputClientRectJSON);

      expect(
          initialInputClientRectRelativeToViewport['bottom'] <=
              viewportRectRelativeToViewport['bottom'],
          isFalse);

      await controller.evaluateJavascript('inputEl.focus()');

      // Check that focusing the input brought it into view.

      final String lastInputClientRectJSON = await _evaluateJavascript(
          controller, 'JSON.stringify(inputEl.getBoundingClientRect())');
      final Map<String, dynamic> lastInputClientRectRelativeToViewport =
          jsonDecode(lastInputClientRectJSON);

      expect(
          lastInputClientRectRelativeToViewport['top'] >=
              viewportRectRelativeToViewport['top'],
          isTrue);
      expect(
          lastInputClientRectRelativeToViewport['bottom'] <=
              viewportRectRelativeToViewport['bottom'],
          isTrue);

      expect(
          lastInputClientRectRelativeToViewport['left'] >=
              viewportRectRelativeToViewport['left'],
          isTrue);
      expect(
          lastInputClientRectRelativeToViewport['right'] <=
              viewportRectRelativeToViewport['right'],
          isTrue);
    }, skip: true);
  });

  group('NavigationDelegate', () {
    final String blankPage = "<!DOCTYPE html><head></head><body></body></html>";
    final String blankPageEncoded = 'data:text/html;charset=utf-8;base64,' +
        base64Encode(const Utf8Encoder().convert(blankPage));

    testWidgets('can allow requests', (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: blankPageEncoded,
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              return (request.url.contains('youtube.com'))
                  ? NavigationDecision.prevent
                  : NavigationDecision.navigate;
            },
            onPageFinished: (String url) => pageLoads.add(url),
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final WebViewController controller = await controllerCompleter.future;
      await controller
          .evaluateJavascript('location.href = "https://www.google.com/"');

      await pageLoads.stream.first; // Wait for the next page load.
      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, 'https://www.google.com/');
    });

    testWidgets('onWebResourceError', (WidgetTester tester) async {
      final Completer<WebResourceError> errorCompleter =
          Completer<WebResourceError>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'https://www.notawebsite..com',
            onWebResourceError: (WebResourceError error) {
              errorCompleter.complete(error);
            },
          ),
        ),
      );

      final WebResourceError error = await errorCompleter.future;
      expect(error, isNotNull);

      if (Platform.isIOS) {
        expect(error.domain, isNotNull);
        expect(error.failingUrl, isNull);
      } else if (Platform.isAndroid) {
        expect(error.errorType, isNotNull);
        expect(error.failingUrl?.startsWith('https://www.notawebsite..com'),
            isTrue);
      }
    });

    testWidgets('onWebResourceError is not called with valid url',
        (WidgetTester tester) async {
      final Completer<WebResourceError> errorCompleter =
          Completer<WebResourceError>();
      final Completer<void> pageFinishCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl:
                'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
            onWebResourceError: (WebResourceError error) {
              errorCompleter.complete(error);
            },
            onPageFinished: (_) => pageFinishCompleter.complete(),
          ),
        ),
      );

      expect(errorCompleter.future, doesNotComplete);
      await pageFinishCompleter.future;
    });

    testWidgets(
      'onWebResourceError only called for main frame',
      (WidgetTester tester) async {
        final String iframeTest = '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>WebResourceError test</title>
        </head>
        <body>
          <iframe src="https://notawebsite..com"></iframe>
        </body>
        </html>
       ''';
        final String iframeTestBase64 =
            base64Encode(const Utf8Encoder().convert(iframeTest));

        final Completer<WebResourceError> errorCompleter =
            Completer<WebResourceError>();
        final Completer<void> pageFinishCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: WebView(
              key: GlobalKey(),
              initialUrl:
                  'data:text/html;charset=utf-8;base64,$iframeTestBase64',
              onWebResourceError: (WebResourceError error) {
                errorCompleter.complete(error);
              },
              onPageFinished: (_) => pageFinishCompleter.complete(),
            ),
          ),
        );

        expect(errorCompleter.future, doesNotComplete);
        await pageFinishCompleter.future;
      },
    );

    testWidgets('can block requests', (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: blankPageEncoded,
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              return (request.url.contains('youtube.com'))
                  ? NavigationDecision.prevent
                  : NavigationDecision.navigate;
            },
            onPageFinished: (String url) => pageLoads.add(url),
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final WebViewController controller = await controllerCompleter.future;
      await controller
          .evaluateJavascript('location.href = "https://www.youtube.com/"');

      // There should never be any second page load, since our new URL is
      // blocked. Still wait for a potential page change for some time in order
      // to give the test a chance to fail.
      await pageLoads.stream.first
          .timeout(const Duration(milliseconds: 500), onTimeout: () => '');
      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, isNot(contains('youtube.com')));
    });

    testWidgets('supports asynchronous decisions', (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: blankPageEncoded,
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) async {
              NavigationDecision decision = NavigationDecision.prevent;
              decision = await Future<NavigationDecision>.delayed(
                  const Duration(milliseconds: 10),
                  () => NavigationDecision.navigate);
              return decision;
            },
            onPageFinished: (String url) => pageLoads.add(url),
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final WebViewController controller = await controllerCompleter.future;
      await controller
          .evaluateJavascript('location.href = "https://www.google.com"');

      await pageLoads.stream.first; // Wait for second page to load.
      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, 'https://www.google.com/');
    });
  });

  testWidgets('launches with gestureNavigationEnabled on iOS',
      (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'https://flutter.dev/',
            gestureNavigationEnabled: true,
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
          ),
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter.dev/');
  });

  testWidgets('target _blank opens in same window',
      (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            pageLoaded.complete(null);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await controller
        .evaluateJavascript('window.open("https://flutter.dev/", "_blank")');
    await pageLoaded.future;
    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter.dev/');
  },
      // Flaky on Android: https://github.com/flutter/flutter/issues/86757
      skip: Platform.isAndroid);

  // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757.
  testWidgets(
    'can open new window and go back',
    (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      Completer<void> pageLoaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              pageLoaded.complete();
            },
            initialUrl: 'https://flutter.dev',
          ),
        ),
      );
      final WebViewController controller = await controllerCompleter.future;
      expect(controller.currentUrl(), completion('https://flutter.dev/'));
      await pageLoaded.future;
      pageLoaded = Completer<void>();

      await controller
          .evaluateJavascript('window.open("https://www.google.com/")');
      await pageLoaded.future;
      pageLoaded = Completer<void>();
      expect(controller.currentUrl(), completion('https://www.google.com/'));

      expect(controller.canGoBack(), completion(true));
      await controller.goBack();
      await pageLoaded.future;
      expect(controller.currentUrl(), completion('https://flutter.dev/'));
    },
    skip: true,
  );

  testWidgets(
    'javascript does not run in parent window',
    (WidgetTester tester) async {
      final String iframe = '''
        <!DOCTYPE html>
        <script>
          window.onload = () => {
            window.open(`javascript:
              var elem = document.createElement("p");
              elem.innerHTML = "<b>Executed JS in parent origin: " + window.location.origin + "</b>";
              document.body.append(elem);
            `);
          };
        </script>
      ''';
      final String iframeTestBase64 =
          base64Encode(const Utf8Encoder().convert(iframe));

      final String openWindowTest = '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>XSS test</title>
        </head>
        <body>
          <iframe
            onload="window.iframeLoaded = true;"
            src="data:text/html;charset=utf-8;base64,$iframeTestBase64"></iframe>
        </body>
        </html>
      ''';
      final String openWindowTestBase64 =
          base64Encode(const Utf8Encoder().convert(openWindowTest));
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      final Completer<void> pageLoadCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl:
                'data:text/html;charset=utf-8;base64,$openWindowTestBase64',
            onPageFinished: (String url) {
              pageLoadCompleter.complete();
            },
          ),
        ),
      );

      final WebViewController controller = await controllerCompleter.future;
      await pageLoadCompleter.future;

      expect(controller.evaluateJavascript('iframeLoaded'), completion('true'));
      expect(
        controller.evaluateJavascript(
            'document.querySelector("p") && document.querySelector("p").textContent'),
        completion('null'),
      );
    },
    skip: !Platform.isAndroid,
  );
}

// JavaScript booleans evaluate to different string values on Android and iOS.
// This utility method returns the string boolean value of the current platform.
String _webviewBool(bool value) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return value ? '1' : '0';
  }
  return value ? 'true' : 'false';
}

/// Returns the value used for the HTTP User-Agent: request header in subsequent HTTP requests.
Future<String> _getUserAgent(WebViewController controller) async {
  return _evaluateJavascript(controller, 'navigator.userAgent;');
}

Future<String> _evaluateJavascript(
    WebViewController controller, String js) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return await controller.evaluateJavascript(js);
  }
  return jsonDecode(await controller.evaluateJavascript(js));
}
