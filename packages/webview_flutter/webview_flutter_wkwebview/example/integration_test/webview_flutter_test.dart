// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This test is run using `flutter drive` by the CI (see /script/tool/README.md
// in this repository for details on driving that tooling manually), but can
// also be run using `flutter test` directly during development.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/weak_reference_utils.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
  server.forEach((HttpRequest request) {
    if (request.uri.path == '/hello.txt') {
      request.response.writeln('Hello, world.');
    } else if (request.uri.path == '/secondary.txt') {
      request.response.writeln('How are you today?');
    } else if (request.uri.path == '/headers') {
      request.response.writeln('${request.headers}');
    } else if (request.uri.path == '/favicon.ico') {
      request.response.statusCode = HttpStatus.notFound;
    } else {
      fail('unexpected request: ${request.method} ${request.uri}');
    }
    request.response.close();
  });
  final String prefixUrl = 'http://${server.address.address}:${server.port}';
  final String primaryUrl = '$prefixUrl/hello.txt';
  final String secondaryUrl = '$prefixUrl/secondary.txt';
  final String headersUrl = '$prefixUrl/headers';

  WebViewPlatform.instance = WebKitWebViewPlatform();

  testWidgets(
      'withWeakRefenceTo allows encapsulating class to be garbage collected',
      (WidgetTester tester) async {
    final Completer<int> gcCompleter = Completer<int>();
    final InstanceManager instanceManager = InstanceManager(
      onWeakReferenceRemoved: gcCompleter.complete,
    );

    ClassWithCallbackClass? instance = ClassWithCallbackClass();
    instanceManager.addHostCreatedInstance(instance.callbackClass, 0);
    instance = null;

    // Force garbage collection.
    await IntegrationTestWidgetsFlutterBinding.instance
        .watchPerformance(() async {
      await tester.pumpAndSettle();
    });

    final int gcIdentifier = await gcCompleter.future;
    expect(gcIdentifier, 0);
  }, timeout: const Timeout(Duration(seconds: 10)));

  testWidgets('loadRequest', (WidgetTester tester) async {
    final PlatformWebViewController controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    );
    controller.loadRequest(LoadRequestParams(uri: Uri.parse(primaryUrl)));

    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, primaryUrl);
  });

  testWidgets('runJavaScriptReturningResult', (WidgetTester tester) async {
    final PlatformWebViewController controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    );
    controller.loadRequest(LoadRequestParams(uri: Uri.parse(primaryUrl)));

    await expectLater(
      controller.runJavaScriptReturningResult('1 + 1'),
      completion(2),
    );
  });

  testWidgets('loadRequest with headers', (WidgetTester tester) async {
    final Map<String, String> headers = <String, String>{
      'test_header': 'flutter_test_header'
    };

    final StreamController<String> pageLoads = StreamController<String>();

    final PlatformWebViewController controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setPlatformNavigationDelegate(
        WebKitNavigationDelegate(
          const WebKitNavigationDelegateCreationParams(),
        )..setOnPageFinished((String url) => pageLoads.add(url)),
      )
      ..loadRequest(
        LoadRequestParams(
          uri: Uri.parse(headersUrl),
          headers: headers,
        ),
      );

    await pageLoads.stream.firstWhere((String url) => url == headersUrl);

    final String content = await controller.runJavaScriptReturningResult(
      'document.documentElement.innerText',
    ) as String;
    expect(content.contains('flutter_test_header'), isTrue);
  });

  testWidgets('JavascriptChannel', (WidgetTester tester) async {
    final Completer<void> pageFinished = Completer<void>();
    final PlatformWebViewController controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setPlatformNavigationDelegate(
        WebKitNavigationDelegate(
          const WebKitNavigationDelegateCreationParams(),
        )..setOnPageFinished((_) => pageFinished.complete()),
      );

    final Completer<String> channelCompleter = Completer<String>();
    await controller.addJavaScriptChannel(
      JavaScriptChannelParams(
        name: 'Echo',
        onMessageReceived: (JavaScriptMessage message) {
          channelCompleter.complete(message.message);
        },
      ),
    );

    controller.loadHtmlString(
      'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
    );

    await pageFinished.future;

    await controller.runJavaScript('Echo.postMessage("hello");');
    await expectLater(channelCompleter.future, completion('hello'));
  });

  testWidgets('resize webview', (WidgetTester tester) async {
    final Completer<void> buttonTapResizeCompleter = Completer<void>();
    final Completer<void> onPageFinished = Completer<void>();

    bool resizeButtonTapped = false;
    await tester.pumpWidget(ResizableWebView(
      onResize: () {
        if (resizeButtonTapped) {
          buttonTapResizeCompleter.complete();
        }
      },
      onPageFinished: () => onPageFinished.complete(),
    ));

    await onPageFinished.future;

    resizeButtonTapped = true;

    await tester.tap(find.byKey(const ValueKey<String>('resizeButton')));
    await tester.pumpAndSettle();

    await expectLater(buttonTapResizeCompleter.future, completes);
  });

  testWidgets('set custom userAgent', (WidgetTester tester) async {
    final PlatformWebViewController controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Custom_User_Agent1');

    final String customUserAgent2 = await _getUserAgent(controller);
    expect(customUserAgent2, 'Custom_User_Agent1');
  });

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
      Completer<void> pageLoaded = Completer<void>();

      PlatformWebViewController controller = PlatformWebViewController(
        WebKitWebViewControllerCreationParams(
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        ),
      )
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setPlatformNavigationDelegate(
          WebKitNavigationDelegate(
            const WebKitNavigationDelegateCreationParams(),
          )..setOnPageFinished((_) => pageLoaded.complete()),
        )
        ..loadRequest(
          LoadRequestParams(
            uri: Uri.parse(
              'data:text/html;charset=utf-8;base64,$videoTestBase64',
            ),
          ),
        );

      await pageLoaded.future;

      bool isPaused =
          await controller.runJavaScriptReturningResult('isPaused();') as bool;
      expect(isPaused, false);

      pageLoaded = Completer<void>();
      controller = PlatformWebViewController(
        WebKitWebViewControllerCreationParams(),
      )
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setPlatformNavigationDelegate(
          WebKitNavigationDelegate(
            const WebKitNavigationDelegateCreationParams(),
          )..setOnPageFinished((_) => pageLoaded.complete()),
        )
        ..loadRequest(
          LoadRequestParams(
            uri: Uri.parse(
              'data:text/html;charset=utf-8;base64,$videoTestBase64',
            ),
          ),
        );

      await pageLoaded.future;

      isPaused =
          await controller.runJavaScriptReturningResult('isPaused();') as bool;
      expect(isPaused, true);
    });

    testWidgets('Video plays inline when allowsInlineMediaPlayback is true',
        (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();
      final PlatformWebViewController controller =
          PlatformWebViewController(WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      ))
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setPlatformNavigationDelegate(
              WebKitNavigationDelegate(
                const WebKitNavigationDelegateCreationParams(),
              )..setOnPageFinished((_) => pageLoaded.complete()),
            )
            ..loadRequest(
              LoadRequestParams(
                uri: Uri.parse(
                  'data:text/html;charset=utf-8;base64,$videoTestBase64',
                ),
              ),
            );

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
                  if (currentTime > 1 && !videoPlaying.isCompleted) {
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
      final WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      // Pump once to trigger the video play.
      await tester.pump();

      // Makes sure we get the correct event that indicates the video is actually playing.
      await videoPlaying.future;

      final String fullScreen =
          await controller.runJavascriptReturningResult('isFullScreen();');
      expect(fullScreen, _webviewBool(false));
    });
    //
    //   testWidgets(
    //       'Video plays full screen when allowsInlineMediaPlayback is false',
    //       (WidgetTester tester) async {
    //     final Completer<WebViewController> controllerCompleter =
    //         Completer<WebViewController>();
    //     final Completer<void> pageLoaded = Completer<void>();
    //     final Completer<void> videoPlaying = Completer<void>();
    //
    //     await tester.pumpWidget(
    //       Directionality(
    //         textDirection: TextDirection.ltr,
    //         child: WebView(
    //           initialUrl: 'data:text/html;charset=utf-8;base64,$videoTestBase64',
    //           onWebViewCreated: (WebViewController controller) {
    //             controllerCompleter.complete(controller);
    //           },
    //           javascriptMode: JavascriptMode.unrestricted,
    //           javascriptChannels: <JavascriptChannel>{
    //             JavascriptChannel(
    //               name: 'VideoTestTime',
    //               onMessageReceived: (JavascriptMessage message) {
    //                 final double currentTime = double.parse(message.message);
    //                 // Let it play for at least 1 second to make sure the related video's properties are set.
    //                 if (currentTime > 1 && !videoPlaying.isCompleted) {
    //                   videoPlaying.complete(null);
    //                 }
    //               },
    //             ),
    //           },
    //           onPageFinished: (String url) {
    //             pageLoaded.complete(null);
    //           },
    //           initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
    //         ),
    //       ),
    //     );
    //     final WebViewController controller = await controllerCompleter.future;
    //     await pageLoaded.future;
    //
    //     // Pump once to trigger the video play.
    //     await tester.pump();
    //
    //     // Makes sure we get the correct event that indicates the video is actually playing.
    //     await videoPlaying.future;
    //
    //     final String fullScreen =
    //         await controller.runJavascriptReturningResult('isFullScreen();');
    //     expect(fullScreen, _webviewBool(true));
    //   });
  });
  //
  // group('Audio playback policy', () {
  //   late String audioTestBase64;
  //   setUpAll(() async {
  //     final ByteData audioData =
  //         await rootBundle.load('assets/sample_audio.ogg');
  //     final String base64AudioData =
  //         base64Encode(Uint8List.view(audioData.buffer));
  //     final String audioTest = '''
  //       <!DOCTYPE html><html>
  //       <head><title>Audio auto play</title>
  //         <script type="text/javascript">
  //           function play() {
  //             var audio = document.getElementById("audio");
  //             audio.play();
  //           }
  //           function isPaused() {
  //             var audio = document.getElementById("audio");
  //             return audio.paused;
  //           }
  //         </script>
  //       </head>
  //       <body onload="play();">
  //       <audio controls id="audio">
  //         <source src="data:audio/ogg;charset=utf-8;base64,$base64AudioData">
  //       </audio>
  //       </body>
  //       </html>
  //     ''';
  //     audioTestBase64 = base64Encode(const Utf8Encoder().convert(audioTest));
  //   });
  //
  //   testWidgets('Auto media playback', (WidgetTester tester) async {
  //     Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //     Completer<void> pageStarted = Completer<void>();
  //     Completer<void> pageLoaded = Completer<void>();
  //
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           onPageStarted: (String url) {
  //             pageStarted.complete(null);
  //           },
  //           onPageFinished: (String url) {
  //             pageLoaded.complete(null);
  //           },
  //           initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
  //         ),
  //       ),
  //     );
  //     WebViewController controller = await controllerCompleter.future;
  //     await pageStarted.future;
  //     await pageLoaded.future;
  //
  //     String isPaused =
  //         await controller.runJavascriptReturningResult('isPaused();');
  //     expect(isPaused, _webviewBool(false));
  //
  //     controllerCompleter = Completer<WebViewController>();
  //     pageStarted = Completer<void>();
  //     pageLoaded = Completer<void>();
  //
  //     // We change the key to re-create a new webview as we change the initialMediaPlaybackPolicy
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           onPageStarted: (String url) {
  //             pageStarted.complete(null);
  //           },
  //           onPageFinished: (String url) {
  //             pageLoaded.complete(null);
  //           },
  //         ),
  //       ),
  //     );
  //
  //     controller = await controllerCompleter.future;
  //     await pageStarted.future;
  //     await pageLoaded.future;
  //
  //     isPaused = await controller.runJavascriptReturningResult('isPaused();');
  //     expect(isPaused, _webviewBool(true));
  //   });
  //
  //   testWidgets('Changes to initialMediaPlaybackPolicy are ignored',
  //       (WidgetTester tester) async {
  //     final Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //     Completer<void> pageStarted = Completer<void>();
  //     Completer<void> pageLoaded = Completer<void>();
  //
  //     final GlobalKey key = GlobalKey();
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: key,
  //           initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           onPageStarted: (String url) {
  //             pageStarted.complete(null);
  //           },
  //           onPageFinished: (String url) {
  //             pageLoaded.complete(null);
  //           },
  //           initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
  //         ),
  //       ),
  //     );
  //     final WebViewController controller = await controllerCompleter.future;
  //     await pageStarted.future;
  //     await pageLoaded.future;
  //
  //     String isPaused =
  //         await controller.runJavascriptReturningResult('isPaused();');
  //     expect(isPaused, _webviewBool(false));
  //
  //     pageStarted = Completer<void>();
  //     pageLoaded = Completer<void>();
  //
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: key,
  //           initialUrl: 'data:text/html;charset=utf-8;base64,$audioTestBase64',
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           onPageStarted: (String url) {
  //             pageStarted.complete(null);
  //           },
  //           onPageFinished: (String url) {
  //             pageLoaded.complete(null);
  //           },
  //         ),
  //       ),
  //     );
  //
  //     await controller.reload();
  //
  //     await pageStarted.future;
  //     await pageLoaded.future;
  //
  //     isPaused = await controller.runJavascriptReturningResult('isPaused();');
  //     expect(isPaused, _webviewBool(false));
  //   });
  // });
  //
  // testWidgets('getTitle', (WidgetTester tester) async {
  //   const String getTitleTest = '''
  //       <!DOCTYPE html><html>
  //       <head><title>Some title</title>
  //       </head>
  //       <body>
  //       </body>
  //       </html>
  //     ''';
  //   final String getTitleTestBase64 =
  //       base64Encode(const Utf8Encoder().convert(getTitleTest));
  //   final Completer<void> pageStarted = Completer<void>();
  //   final Completer<void> pageLoaded = Completer<void>();
  //   final Completer<WebViewController> controllerCompleter =
  //       Completer<WebViewController>();
  //
  //   await tester.pumpWidget(
  //     Directionality(
  //       textDirection: TextDirection.ltr,
  //       child: WebView(
  //         initialUrl: 'data:text/html;charset=utf-8;base64,$getTitleTestBase64',
  //         javascriptMode: JavascriptMode.unrestricted,
  //         onWebViewCreated: (WebViewController controller) {
  //           controllerCompleter.complete(controller);
  //         },
  //         onPageStarted: (String url) {
  //           pageStarted.complete(null);
  //         },
  //         onPageFinished: (String url) {
  //           pageLoaded.complete(null);
  //         },
  //       ),
  //     ),
  //   );
  //
  //   final WebViewController controller = await controllerCompleter.future;
  //   await pageStarted.future;
  //   await pageLoaded.future;
  //
  //   // On at least iOS, it does not appear to be guaranteed that the native
  //   // code has the title when the page load completes. Execute some JavaScript
  //   // before checking the title to ensure that the page has been fully parsed
  //   // and processed.
  //   await controller.runJavascript('1;');
  //
  //   final String? title = await controller.getTitle();
  //   expect(title, 'Some title');
  // });
  //
  // group('Programmatic Scroll', () {
  //   testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
  //     const String scrollTestPage = '''
  //       <!DOCTYPE html>
  //       <html>
  //         <head>
  //           <style>
  //             body {
  //               height: 100%;
  //               width: 100%;
  //             }
  //             #container{
  //               width:5000px;
  //               height:5000px;
  //           }
  //           </style>
  //         </head>
  //         <body>
  //           <div id="container"/>
  //         </body>
  //       </html>
  //     ''';
  //
  //     final String scrollTestPageBase64 =
  //         base64Encode(const Utf8Encoder().convert(scrollTestPage));
  //
  //     final Completer<void> pageLoaded = Completer<void>();
  //     final Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           initialUrl:
  //               'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           onPageFinished: (String url) {
  //             pageLoaded.complete(null);
  //           },
  //         ),
  //       ),
  //     );
  //
  //     final WebViewController controller = await controllerCompleter.future;
  //     await pageLoaded.future;
  //
  //     await tester.pumpAndSettle(const Duration(seconds: 3));
  //
  //     int scrollPosX = await controller.getScrollX();
  //     int scrollPosY = await controller.getScrollY();
  //
  //     // Check scrollTo()
  //     const int X_SCROLL = 123;
  //     const int Y_SCROLL = 321;
  //     // Get the initial position; this ensures that scrollTo is actually
  //     // changing something, but also gives the native view's scroll position
  //     // time to settle.
  //     expect(scrollPosX, isNot(X_SCROLL));
  //     expect(scrollPosX, isNot(Y_SCROLL));
  //
  //     await controller.scrollTo(X_SCROLL, Y_SCROLL);
  //     scrollPosX = await controller.getScrollX();
  //     scrollPosY = await controller.getScrollY();
  //     expect(scrollPosX, X_SCROLL);
  //     expect(scrollPosY, Y_SCROLL);
  //
  //     // Check scrollBy() (on top of scrollTo())
  //     await controller.scrollBy(X_SCROLL, Y_SCROLL);
  //     scrollPosX = await controller.getScrollX();
  //     scrollPosY = await controller.getScrollY();
  //     expect(scrollPosX, X_SCROLL * 2);
  //     expect(scrollPosY, Y_SCROLL * 2);
  //   });
  // });
  //
  // group('NavigationDelegate', () {
  //   const String blankPage = '<!DOCTYPE html><head></head><body></body></html>';
  //   final String blankPageEncoded = 'data:text/html;charset=utf-8;base64,'
  //       '${base64Encode(const Utf8Encoder().convert(blankPage))}';
  //
  //   testWidgets('can allow requests', (WidgetTester tester) async {
  //     final Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //     final StreamController<String> pageLoads =
  //         StreamController<String>.broadcast();
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: blankPageEncoded,
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           navigationDelegate: (NavigationRequest request) {
  //             return (request.url.contains('youtube.com'))
  //                 ? NavigationDecision.prevent
  //                 : NavigationDecision.navigate;
  //           },
  //           onPageFinished: (String url) => pageLoads.add(url),
  //         ),
  //       ),
  //     );
  //
  //     await pageLoads.stream.first; // Wait for initial page load.
  //     final WebViewController controller = await controllerCompleter.future;
  //     await controller.runJavascript('location.href = "$secondaryUrl"');
  //
  //     await pageLoads.stream.first; // Wait for the next page load.
  //     final String? currentUrl = await controller.currentUrl();
  //     expect(currentUrl, secondaryUrl);
  //   });
  //
  //   testWidgets('onWebResourceError', (WidgetTester tester) async {
  //     final Completer<WebResourceError> errorCompleter =
  //         Completer<WebResourceError>();
  //
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: 'https://www.notawebsite..com',
  //           onWebResourceError: (WebResourceError error) {
  //             errorCompleter.complete(error);
  //           },
  //         ),
  //       ),
  //     );
  //
  //     final WebResourceError error = await errorCompleter.future;
  //     expect(error, isNotNull);
  //
  //     if (Platform.isIOS) {
  //       expect(error.domain, isNotNull);
  //       expect(error.failingUrl, isNull);
  //     } else if (Platform.isAndroid) {
  //       expect(error.errorType, isNotNull);
  //       expect(error.failingUrl?.startsWith('https://www.notawebsite..com'),
  //           isTrue);
  //     }
  //   });
  //
  //   testWidgets('onWebResourceError is not called with valid url',
  //       (WidgetTester tester) async {
  //     final Completer<WebResourceError> errorCompleter =
  //         Completer<WebResourceError>();
  //     final Completer<void> pageFinishCompleter = Completer<void>();
  //
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl:
  //               'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
  //           onWebResourceError: (WebResourceError error) {
  //             errorCompleter.complete(error);
  //           },
  //           onPageFinished: (_) => pageFinishCompleter.complete(),
  //         ),
  //       ),
  //     );
  //
  //     expect(errorCompleter.future, doesNotComplete);
  //     await pageFinishCompleter.future;
  //   });
  //
  //   testWidgets(
  //     'onWebResourceError only called for main frame',
  //     (WidgetTester tester) async {
  //       const String iframeTest = '''
  //       <!DOCTYPE html>
  //       <html>
  //       <head>
  //         <title>WebResourceError test</title>
  //       </head>
  //       <body>
  //         <iframe src="https://notawebsite..com"></iframe>
  //       </body>
  //       </html>
  //      ''';
  //       final String iframeTestBase64 =
  //           base64Encode(const Utf8Encoder().convert(iframeTest));
  //
  //       final Completer<WebResourceError> errorCompleter =
  //           Completer<WebResourceError>();
  //       final Completer<void> pageFinishCompleter = Completer<void>();
  //
  //       await tester.pumpWidget(
  //         Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: WebView(
  //             key: GlobalKey(),
  //             initialUrl:
  //                 'data:text/html;charset=utf-8;base64,$iframeTestBase64',
  //             onWebResourceError: (WebResourceError error) {
  //               errorCompleter.complete(error);
  //             },
  //             onPageFinished: (_) => pageFinishCompleter.complete(),
  //           ),
  //         ),
  //       );
  //
  //       expect(errorCompleter.future, doesNotComplete);
  //       await pageFinishCompleter.future;
  //     },
  //   );
  //
  //   testWidgets('can block requests', (WidgetTester tester) async {
  //     final Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //     final StreamController<String> pageLoads =
  //         StreamController<String>.broadcast();
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: blankPageEncoded,
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           navigationDelegate: (NavigationRequest request) {
  //             return (request.url.contains('youtube.com'))
  //                 ? NavigationDecision.prevent
  //                 : NavigationDecision.navigate;
  //           },
  //           onPageFinished: (String url) => pageLoads.add(url),
  //         ),
  //       ),
  //     );
  //
  //     await pageLoads.stream.first; // Wait for initial page load.
  //     final WebViewController controller = await controllerCompleter.future;
  //     await controller
  //         .runJavascript('location.href = "https://www.youtube.com/"');
  //
  //     // There should never be any second page load, since our new URL is
  //     // blocked. Still wait for a potential page change for some time in order
  //     // to give the test a chance to fail.
  //     await pageLoads.stream.first
  //         .timeout(const Duration(milliseconds: 500), onTimeout: () => '');
  //     final String? currentUrl = await controller.currentUrl();
  //     expect(currentUrl, isNot(contains('youtube.com')));
  //   });
  //
  //   testWidgets('supports asynchronous decisions', (WidgetTester tester) async {
  //     final Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //     final StreamController<String> pageLoads =
  //         StreamController<String>.broadcast();
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: blankPageEncoded,
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           navigationDelegate: (NavigationRequest request) async {
  //             NavigationDecision decision = NavigationDecision.prevent;
  //             decision = await Future<NavigationDecision>.delayed(
  //                 const Duration(milliseconds: 10),
  //                 () => NavigationDecision.navigate);
  //             return decision;
  //           },
  //           onPageFinished: (String url) => pageLoads.add(url),
  //         ),
  //       ),
  //     );
  //
  //     await pageLoads.stream.first; // Wait for initial page load.
  //     final WebViewController controller = await controllerCompleter.future;
  //     await controller.runJavascript('location.href = "$secondaryUrl"');
  //
  //     await pageLoads.stream.first; // Wait for second page to load.
  //     final String? currentUrl = await controller.currentUrl();
  //     expect(currentUrl, secondaryUrl);
  //   });
  // });
  //
  // testWidgets('launches with gestureNavigationEnabled on iOS',
  //     (WidgetTester tester) async {
  //   final Completer<WebViewController> controllerCompleter =
  //       Completer<WebViewController>();
  //   await tester.pumpWidget(
  //     Directionality(
  //       textDirection: TextDirection.ltr,
  //       child: SizedBox(
  //         width: 400,
  //         height: 300,
  //         child: WebView(
  //           key: GlobalKey(),
  //           initialUrl: primaryUrl,
  //           gestureNavigationEnabled: true,
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  //   final WebViewController controller = await controllerCompleter.future;
  //   final String? currentUrl = await controller.currentUrl();
  //   expect(currentUrl, primaryUrl);
  // });
  //
  // testWidgets('target _blank opens in same window',
  //     (WidgetTester tester) async {
  //   final Completer<WebViewController> controllerCompleter =
  //       Completer<WebViewController>();
  //   final Completer<void> pageLoaded = Completer<void>();
  //   await tester.pumpWidget(
  //     Directionality(
  //       textDirection: TextDirection.ltr,
  //       child: WebView(
  //         key: GlobalKey(),
  //         onWebViewCreated: (WebViewController controller) {
  //           controllerCompleter.complete(controller);
  //         },
  //         javascriptMode: JavascriptMode.unrestricted,
  //         onPageFinished: (String url) {
  //           pageLoaded.complete(null);
  //         },
  //       ),
  //     ),
  //   );
  //   final WebViewController controller = await controllerCompleter.future;
  //   await controller.runJavascript('window.open("$primaryUrl", "_blank")');
  //   await pageLoaded.future;
  //   final String? currentUrl = await controller.currentUrl();
  //   expect(currentUrl, primaryUrl);
  // });
  //
  // testWidgets(
  //   'can open new window and go back',
  //   (WidgetTester tester) async {
  //     final Completer<WebViewController> controllerCompleter =
  //         Completer<WebViewController>();
  //     Completer<void> pageLoaded = Completer<void>();
  //     await tester.pumpWidget(
  //       Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: WebView(
  //           key: GlobalKey(),
  //           onWebViewCreated: (WebViewController controller) {
  //             controllerCompleter.complete(controller);
  //           },
  //           javascriptMode: JavascriptMode.unrestricted,
  //           onPageFinished: (String url) {
  //             pageLoaded.complete();
  //           },
  //           initialUrl: primaryUrl,
  //         ),
  //       ),
  //     );
  //     final WebViewController controller = await controllerCompleter.future;
  //     expect(controller.currentUrl(), completion(primaryUrl));
  //     await pageLoaded.future;
  //     pageLoaded = Completer<void>();
  //
  //     await controller.runJavascript('window.open("$secondaryUrl")');
  //     await pageLoaded.future;
  //     pageLoaded = Completer<void>();
  //     expect(controller.currentUrl(), completion(secondaryUrl));
  //
  //     expect(controller.canGoBack(), completion(true));
  //     await controller.goBack();
  //     await pageLoaded.future;
  //     await expectLater(controller.currentUrl(), completion(primaryUrl));
  //   },
  // );
}

// // JavaScript booleans evaluate to different string values on Android and iOS.
// // This utility method returns the string boolean value of the current platform.
// String _webviewBool(bool value) {
//   if (defaultTargetPlatform == TargetPlatform.iOS) {
//     return value ? '1' : '0';
//   }
//   return value ? 'true' : 'false';
// }
//
/// Returns the value used for the HTTP User-Agent: request header in subsequent HTTP requests.
Future<String> _getUserAgent(PlatformWebViewController controller) async {
  return await controller.runJavaScriptReturningResult('navigator.userAgent;')
      as String;
}

class ResizableWebView extends StatefulWidget {
  const ResizableWebView({
    Key? key,
    required this.onResize,
    required this.onPageFinished,
  }) : super(key: key);

  final VoidCallback onResize;
  final VoidCallback onPageFinished;

  @override
  State<StatefulWidget> createState() => ResizableWebViewState();
}

class ResizableWebViewState extends State<ResizableWebView> {
  late final PlatformWebViewController controller = PlatformWebViewController(
    const PlatformWebViewControllerCreationParams(),
  )
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setPlatformNavigationDelegate(
      WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      )..setOnPageFinished((_) => widget.onPageFinished()),
    )
    ..addJavaScriptChannel(
      JavaScriptChannelParams(
        name: 'Resize',
        onMessageReceived: (_) {
          widget.onResize();
        },
      ),
    )
    ..loadRequest(
      LoadRequestParams(
        uri: Uri.parse(
          'data:text/html;charset=utf-8;base64,${base64Encode(const Utf8Encoder().convert(resizePage))}',
        ),
      ),
    );

  double webViewWidth = 200;
  double webViewHeight = 200;

  static const String resizePage = '''
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: webViewWidth,
            height: webViewHeight,
            child: PlatformWebViewWidget(
              PlatformWebViewWidgetCreationParams(controller: controller),
            ).build(context),
          ),
          TextButton(
            key: const Key('resizeButton'),
            onPressed: () {
              setState(() {
                webViewWidth += 100.0;
                webViewHeight += 100.0;
              });
            },
            child: const Text('ResizeButton'),
          ),
        ],
      ),
    );
  }
}

class CopyableObjectWithCallback with Copyable {
  CopyableObjectWithCallback(this.callback);

  final VoidCallback callback;

  @override
  CopyableObjectWithCallback copy() {
    return CopyableObjectWithCallback(callback);
  }
}

class ClassWithCallbackClass {
  ClassWithCallbackClass() {
    callbackClass = CopyableObjectWithCallback(
      withWeakRefenceTo(
        this,
        (WeakReference<ClassWithCallbackClass> weakReference) {
          return () {
            // Weak reference to `this` in callback.
            // ignore: unnecessary_statements
            weakReference;
          };
        },
      ),
    );
  }

  late final CopyableObjectWithCallback callbackClass;
}
