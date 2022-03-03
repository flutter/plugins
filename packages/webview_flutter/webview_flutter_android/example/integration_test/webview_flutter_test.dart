// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This test is run using `flutter drive` by the CI (see /script/tool/README.md
// in this repository for details on driving that tooling manually), but can
// also be run using `flutter test` directly during development.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const bool _skipDueToIssue86757 = true;

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

  // Minimial end-to-end testing of the legacy Android implementation.
  group('AndroidWebView (virtual display)', () {
    setUpAll(() {
      WebView.platform = AndroidWebView();
    });

    tearDownAll(() {
      WebView.platform = null;
    });

    testWidgets('initialUrl', (WidgetTester tester) async {
      final Completer<WebViewController> controllerCompleter =
          Completer<WebViewController>();
      final Completer<void> loadCompleter = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: primaryUrl,
            onWebViewCreated: (WebViewController controller) {
              controllerCompleter.complete(controller);
            },
            onPageFinished: (String url) {
              loadCompleter.complete();
            },
          ),
        ),
      );
      final WebViewController controller = await controllerCompleter.future;
      await loadCompleter.future;
      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, primaryUrl);
    });
  }, skip: _skipDueToIssue86757);

  group('SurfaceAndroidWebView', () {
    setUpAll(() {
      WebView.platform = SurfaceAndroidWebView();
    });

    tearDownAll(() {
      WebView.platform = AndroidWebView();
    });

    // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757
    testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
      const String scrollTestPage = '''
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

      await tester.pumpAndSettle(const Duration(seconds: 3));

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
    }, skip: _skipDueToIssue86757);

    // TODO(bparrishMines): skipped due to https://github.com/flutter/flutter/issues/86757
    testWidgets('inputs are scrolled into view when focused',
        (WidgetTester tester) async {
      const String scrollTestPage = '''
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
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      });

      final WebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;
      final String viewportRectJSON = await _runJavaScriptReturningResult(
          controller, 'JSON.stringify(viewport.getBoundingClientRect())');
      final Map<String, dynamic> viewportRectRelativeToViewport =
          jsonDecode(viewportRectJSON) as Map<String, dynamic>;

      // Check that the input is originally outside of the viewport.

      final String initialInputClientRectJSON =
          await _runJavaScriptReturningResult(
              controller, 'JSON.stringify(inputEl.getBoundingClientRect())');
      final Map<String, dynamic> initialInputClientRectRelativeToViewport =
          jsonDecode(initialInputClientRectJSON) as Map<String, dynamic>;

      expect(
          initialInputClientRectRelativeToViewport['bottom'] <=
              viewportRectRelativeToViewport['bottom'],
          isFalse);

      await controller.runJavascript('inputEl.focus()');

      // Check that focusing the input brought it into view.

      final String lastInputClientRectJSON =
          await _runJavaScriptReturningResult(
              controller, 'JSON.stringify(inputEl.getBoundingClientRect())');
      final Map<String, dynamic> lastInputClientRectRelativeToViewport =
          jsonDecode(lastInputClientRectJSON) as Map<String, dynamic>;

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
    }, skip: _skipDueToIssue86757);
  });

  group('NavigationDelegate', () {
    const String blankPage = '<!DOCTYPE html><head></head><body></body></html>';
    final String blankPageEncoded = 'data:text/html;charset=utf-8;base64,' +
        base64Encode(const Utf8Encoder().convert(blankPage));

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
      await controller.runJavascript('location.href = "$secondaryUrl"');

      await pageLoads.stream.first; // Wait for second page to load.
      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, secondaryUrl);
    });
  });

  testWidgets(
    'JavaScript does not run in parent window',
    (WidgetTester tester) async {
      const String iframe = '''
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

      expect(controller.runJavascriptReturningResult('iframeLoaded'),
          completion('true'));
      expect(
        controller.runJavascriptReturningResult(
            'document.querySelector("p") && document.querySelector("p").textContent'),
        completion('null'),
      );
    },
  );
}

Future<String> _runJavaScriptReturningResult(
  WebViewController controller,
  String js,
) async {
  return jsonDecode(await controller.runJavascriptReturningResult(js))
      as String;
}

class ResizableWebView extends StatefulWidget {
  const ResizableWebView({
    required this.onResize,
    required this.onPageFinished,
  });

  final JavascriptMessageHandler onResize;
  final VoidCallback onPageFinished;

  @override
  State<StatefulWidget> createState() => ResizableWebViewState();
}

class ResizableWebViewState extends State<ResizableWebView> {
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
    final String resizeTestBase64 =
        base64Encode(const Utf8Encoder().convert(resizePage));
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: webViewWidth,
            height: webViewHeight,
            child: WebView(
              initialUrl:
                  'data:text/html;charset=utf-8;base64,$resizeTestBase64',
              javascriptChannels: <JavascriptChannel>{
                JavascriptChannel(
                  name: 'Resize',
                  onMessageReceived: widget.onResize,
                ),
              },
              onPageFinished: (_) => widget.onPageFinished(),
              javascriptMode: JavascriptMode.unrestricted,
            ),
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
