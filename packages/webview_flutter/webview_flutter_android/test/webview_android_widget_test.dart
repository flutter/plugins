// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/webview_android_widget.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'webview_android_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  android_webview.WebSettings,
  android_webview.WebView,
  WebViewAndroidDownloadListener,
  WebViewAndroidJavaScriptChannel,
  WebViewAndroidWebChromeClient,
  WebViewAndroidWebViewClient,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewProxy,
  http.Client
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WebViewAndroidWidget', () {
    late MockWebView mockWebView;
    late MockWebSettings mockWebSettings;
    late MockWebViewProxy mockWebViewProxy;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late WebViewAndroidWebViewClient webViewClient;
    late WebViewAndroidDownloadListener downloadListener;
    late WebViewAndroidWebChromeClient webChromeClient;

    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    late WebViewAndroidPlatformController testController;
    late MockClient mockHttpClient;

    setUp(() {
      mockWebView = MockWebView();
      mockWebSettings = MockWebSettings();
      when(mockWebView.settings).thenReturn(mockWebSettings);

      mockWebViewProxy = MockWebViewProxy();
      when(mockWebViewProxy.createWebView(
        useHybridComposition: anyNamed('useHybridComposition'),
      )).thenReturn(mockWebView);

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();
      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();
      mockHttpClient = MockClient();
    });

    // Builds a AndroidWebViewWidget with default parameters.
    Future<void> buildWidget(
      WidgetTester tester, {
      CreationParams? creationParams,
      bool hasNavigationDelegate = false,
      bool hasProgressTracking = false,
      bool useHybridComposition = false,
    }) async {
      await tester.pumpWidget(WebViewAndroidWidget(
        useHybridComposition: useHybridComposition,
        creationParams: creationParams ??
            CreationParams(
                webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: hasNavigationDelegate,
              hasProgressTracking: hasProgressTracking,
            )),
        callbacksHandler: mockCallbacksHandler,
        javascriptChannelRegistry: mockJavascriptChannelRegistry,
        webViewProxy: mockWebViewProxy,
        onBuildWidget: (WebViewAndroidPlatformController controller) {
          testController = controller;
          testController.httpClient = mockHttpClient;
          return Container();
        },
      ));

      webViewClient = testController.webViewClient;
      downloadListener = testController.downloadListener;
      webChromeClient = testController.webChromeClient;
    }

    testWidgets('$WebViewAndroidWidget', (WidgetTester tester) async {
      await buildWidget(tester);

      verify(mockWebSettings.setDomStorageEnabled(true));
      verify(mockWebSettings.setJavaScriptCanOpenWindowsAutomatically(true));
      verify(mockWebSettings.setSupportMultipleWindows(true));
      verify(mockWebSettings.setLoadWithOverviewMode(true));
      verify(mockWebSettings.setUseWideViewPort(true));
      verify(mockWebSettings.setDisplayZoomControls(false));
      verify(mockWebSettings.setBuiltInZoomControls(true));

      verifyInOrder(<Future<void>>[
        mockWebView.setWebViewClient(webViewClient),
        mockWebView.setDownloadListener(downloadListener),
        mockWebView.setWebChromeClient(webChromeClient),
      ]);
    });

    testWidgets(
      'Create Widget with Hybrid Composition',
      (WidgetTester tester) async {
        await buildWidget(tester, useHybridComposition: true);
        verify(mockWebViewProxy.createWebView(useHybridComposition: true));
      },
    );

    group('$CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            initialUrl: 'https://www.google.com',
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );
        verify(mockWebView.loadUrl(
          'https://www.google.com',
          <String, String>{},
        ));
      });

      testWidgets('userAgent', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            userAgent: 'MyUserAgent',
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebSettings.setUserAgentString('MyUserAgent'));
      });

      testWidgets('autoMediaPlaybackPolicy true', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebSettings.setMediaPlaybackRequiresUserGesture(any));
      });

      testWidgets('autoMediaPlaybackPolicy false', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebSettings.setMediaPlaybackRequiresUserGesture(false));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            javascriptChannelNames: <String>{'a', 'b'},
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        final List<dynamic> javaScriptChannels =
            verify(mockWebView.addJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'a');
        expect(javaScriptChannels[1].channelName, 'b');
      });

      group('$WebSettings', () {
        testWidgets('javascriptMode', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                javascriptMode: JavascriptMode.unrestricted,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebSettings.setJavaScriptEnabled(true));
        });

        testWidgets('hasNavigationDelegate', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                hasNavigationDelegate: true,
              ),
            ),
          );

          expect(testController.webViewClient.handlesNavigation, isTrue);
          expect(testController.webViewClient.shouldOverrideUrlLoading, isTrue);
        });

        testWidgets('debuggingEnabled', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                debuggingEnabled: true,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebViewProxy.setWebContentsDebuggingEnabled(true));
        });

        testWidgets('userAgent', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.of('myUserAgent'),
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebSettings.setUserAgentString('myUserAgent'));
        });

        testWidgets('zoomEnabled', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                zoomEnabled: false,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebSettings.setSupportZoom(false));
        });
      });
    });

    group('$WebViewPlatformController', () {
      testWidgets('loadFile without "file://" prefix',
          (WidgetTester tester) async {
        await buildWidget(tester);

        const String filePath = '/path/to/file.html';
        await testController.loadFile(filePath);

        verify(mockWebView.loadUrl(
          'file://$filePath',
          <String, String>{},
        ));
      });

      testWidgets('loadFile with "file://" prefix',
          (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFile('file:///path/to/file.html');

        verify(mockWebView.loadUrl(
          'file:///path/to/file.html',
          <String, String>{},
        ));
      });

      testWidgets('loadHtmlString without base URL',
          (WidgetTester tester) async {
        await buildWidget(tester);

        const String htmlString = '<html><body>Test data.</body></html>';
        await testController.loadHtmlString(htmlString);

        verify(mockWebView.loadDataWithBaseUrl(
          data: htmlString,
          mimeType: 'text/html',
        ));
      });

      testWidgets('loadHtmlString with base URL', (WidgetTester tester) async {
        await buildWidget(tester);

        const String htmlString = '<html><body>Test data.</body></html>';
        await testController.loadHtmlString(
          htmlString,
          baseUrl: 'https://flutter.dev',
        );

        verify(mockWebView.loadDataWithBaseUrl(
          baseUrl: 'https://flutter.dev',
          data: htmlString,
          mimeType: 'text/html',
        ));
      });

      testWidgets('loadUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        verify(mockWebView.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        ));
      });

      group('postUrlAndFollowRedirects', () {
        http.StreamedResponse _buildStreamedResponse(
                Map<String, dynamic> data) =>
            http.StreamedResponse(
              Stream<List<int>>.value(
                  (data['body'] as String? ?? '').codeUnits),
              data['status'] as int,
              headers: (data['headers'] ?? <String, String>{})
                  as Map<String, String>,
            );
        http.Request _buildRequest(Map<String, dynamic> data) {
          final http.Request req = http.Request(
            'POST',
            Uri.parse(data['url'] as String),
          )
            ..followRedirects = false
            ..body = data['body'] as String? ?? '';
          req.headers.addAll(
              data['headers'] as Map<String, String>? ?? <String, String>{});
          return req;
        }

        Future<void> withXRedirects(int redirects) async {
          assert(redirects >= 1);
          // Setup
          final List<http.Request> requests = <Map<String, dynamic>>[
            for (int i = 1; i <= redirects + 1; i++)
              <String, dynamic>{
                'url': 'https://origin-$i',
                'headers': <String, String>{'a': 'header'}
              },
          ].map(_buildRequest).toList();
          final List<http.StreamedResponse> responses = <Map<String, dynamic>>[
            for (int i = 2; i <= redirects + 1; i++)
              <String, dynamic>{
                'status': 300,
                'headers': <String, String>{'location': 'https://origin-$i'}
              },
            <String, dynamic>{
              'body': 'Response Data',
              'status': 200,
              'headers': <String, String>{'content-type': 'text/html'}
            }
          ].map(_buildStreamedResponse).toList();
          final List<http.Request> requestLog = <http.Request>[];
          when(mockHttpClient.send(any))
              .thenAnswer((Invocation invocation) async {
            requestLog.add(invocation.positionalArguments[0] as http.Request);
            return responses.removeAt(0);
          });

          // Run
          final HTTPResponseWithUrl responseWithUrl = await testController
              .postUrlAndFollowRedirects(Uri.parse(requests[0].url.toString()),
                  headers: requests[0].headers, body: requests[0].bodyBytes);

          // Verify
          expect(requestLog.length, equals(requests.length));
          for (int i = 0; i < requestLog.length; i++) {
            expect(requestLog[i], _EqualsHttpRequest(requests[i]));
          }
          expect(
              responseWithUrl.url, equals('https://origin-${redirects + 1}'));
          expect(responseWithUrl.response.body, equals('Response Data'));
          expect(responseWithUrl.response.statusCode, equals(200));
          expect(responseWithUrl.response.headers,
              equals(<String, String>{'content-type': 'text/html'}));
        }

        testWidgets('Succeeds without redirect', (WidgetTester tester) async {
          // Setup
          await buildWidget(tester);
          when(mockHttpClient.send(any)).thenAnswer(
            (_) async => http.StreamedResponse(
              Stream<List<int>>.value('Response Data'.codeUnits),
              200,
              headers: <String, String>{'content-type': 'text/html'},
            ),
          );
          // Run
          final HTTPResponseWithUrl responseWithUrl = await testController
              .postUrlAndFollowRedirects(Uri.parse('https://www.google.com'),
                  headers: <String, String>{'a': 'header'},
                  body: Uint8List.fromList('Test Body'.codeUnits));
          // Verify
          final http.Request expectedRequest =
              http.Request('POST', Uri.parse('https://www.google.com'))
                ..followRedirects = false
                ..bodyBytes = Uint8List.fromList('Test Body'.codeUnits);
          expectedRequest.headers.addAll(<String, String>{'a': 'header'});
          verify(mockHttpClient
              .send(argThat(_EqualsHttpRequest(expectedRequest))));
          expect(responseWithUrl.url, equals('https://www.google.com'));
          expect(responseWithUrl.response.body, equals('Response Data'));
          expect(responseWithUrl.response.statusCode, equals(200));
          expect(responseWithUrl.response.headers,
              equals(<String, String>{'content-type': 'text/html'}));
        });

        testWidgets('Succeeds with 1 redirect', (WidgetTester tester) async {
          await buildWidget(tester);
          withXRedirects(1);
        });

        testWidgets('Succeeds with 2 redirects', (WidgetTester tester) async {
          await buildWidget(tester);
          withXRedirects(2);
        });

        testWidgets('Fails after 20 redirects', (WidgetTester tester) async {
          await buildWidget(tester);
          expect(() => withXRedirects(20),
              throwsA(const TypeMatcher<HttpException>()));
        });
      });

      group('loadRequest', () {
        testWidgets('GET without headers', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
          ));

          verify(mockWebView.loadUrl(
            'https://www.google.com',
            <String, String>{},
          ));
        });

        testWidgets('GET with headers', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
            headers: <String, String>{'a': 'header'},
          ));

          verify(mockWebView.loadUrl(
            'https://www.google.com',
            <String, String>{'a': 'header'},
          ));
        });

        testWidgets('POST without headers or body',
            (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.post,
          ));

          verify(mockWebView.postUrl(
            'https://www.google.com',
            Uint8List(0),
          ));
        });

        testWidgets('POST without headers with body',
            (WidgetTester tester) async {
          await buildWidget(tester);

          final Uint8List body = Uint8List.fromList('Test Body'.codeUnits);

          await testController.loadRequest(WebViewRequest(
              uri: Uri.parse('https://www.google.com'),
              method: WebViewRequestMethod.post,
              body: body));

          verify(mockWebView.postUrl(
            'https://www.google.com',
            body,
          ));
        });

        testWidgets('POST with headers and body', (WidgetTester tester) async {
          // Setup
          await buildWidget(tester);
          when(mockHttpClient.send(any)).thenAnswer((_) async =>
              http.StreamedResponse(
                  Stream<List<int>>.value('Response Data'.codeUnits), 200,
                  headers: <String, String>{'content-type': 'text/html'}));
          final Uint8List body = Uint8List.fromList('Test Body'.codeUnits);
          final Map<String, String> headers = <String, String>{'a': 'header'};
          // Run
          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.post,
            body: body,
            headers: headers,
          ));
          // Verify
          verify(mockWebView.loadDataWithBaseUrl(
              data: 'Response Data',
              baseUrl: 'https://www.google.com',
              mimeType: 'text/html'));
        });
      });

      testWidgets('currentUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getUrl())
            .thenAnswer((_) => Future<String>.value('https://www.google.com'));
        expect(
            testController.currentUrl(), completion('https://www.google.com'));
      });

      testWidgets('canGoBack', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.canGoBack()).thenAnswer(
          (_) => Future<bool>.value(false),
        );
        expect(testController.canGoBack(), completion(false));
      });

      testWidgets('canGoForward', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.canGoForward()).thenAnswer(
          (_) => Future<bool>.value(true),
        );
        expect(testController.canGoForward(), completion(true));
      });

      testWidgets('goBack', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.goBack();
        verify(mockWebView.goBack());
      });

      testWidgets('goForward', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.goForward();
        verify(mockWebView.goForward());
      });

      testWidgets('reload', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.reload();
        verify(mockWebView.reload());
      });

      testWidgets('clearCache', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.clearCache();
        verify(mockWebView.clearCache(true));
      });

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascriptReturningResult', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascriptReturningResult('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels =
            verify(mockWebView.addJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'c');
        expect(javaScriptChannels[1].channelName, 'd');
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        await testController.removeJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels =
            verify(mockWebView.removeJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'c');
        expect(javaScriptChannels[1].channelName, 'd');
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getTitle())
            .thenAnswer((_) => Future<String>.value('Web Title'));
        expect(testController.getTitle(), completion('Web Title'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollTo(1, 2);
        verify(mockWebView.scrollTo(1, 2));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollBy(3, 4);
        verify(mockWebView.scrollBy(3, 4));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getScrollX()).thenAnswer((_) => Future<int>.value(23));
        expect(testController.getScrollX(), completion(23));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getScrollY()).thenAnswer((_) => Future<int>.value(25));
        expect(testController.getScrollY(), completion(25));
      });
    });

    group('$WebViewPlatformCallbacksHandler', () {
      testWidgets('onPageStarted', (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onPageStarted(mockWebView, 'https://google.com');
        verify(mockCallbacksHandler.onPageStarted('https://google.com'));
      });

      testWidgets('onPageFinished', (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onPageFinished(mockWebView, 'https://google.com');
        verify(mockCallbacksHandler.onPageFinished('https://google.com'));
      });

      testWidgets('onWebResourceError from onReceivedError',
          (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onReceivedError(
          mockWebView,
          android_webview.WebViewClient.errorAuthentication,
          'description',
          'https://google.com',
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'description');
        expect(error.errorCode, -4);
        expect(error.failingUrl, 'https://google.com');
        expect(error.domain, isNull);
        expect(error.errorType, WebResourceErrorType.authentication);
      });

      testWidgets('onWebResourceError from onReceivedRequestError',
          (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onReceivedRequestError(
          mockWebView,
          android_webview.WebResourceRequest(
            url: 'https://google.com',
            isForMainFrame: true,
            isRedirect: false,
            hasGesture: false,
            method: 'POST',
            requestHeaders: <String, String>{},
          ),
          android_webview.WebResourceError(
            errorCode: android_webview.WebViewClient.errorUnsafeResource,
            description: 'description',
          ),
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'description');
        expect(error.errorCode, -16);
        expect(error.failingUrl, 'https://google.com');
        expect(error.domain, isNull);
        expect(error.errorType, WebResourceErrorType.unsafeResource);
      });

      testWidgets('onNavigationRequest from urlLoading',
          (WidgetTester tester) async {
        await buildWidget(tester, hasNavigationDelegate: true);
        when(mockCallbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isTrue, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        webViewClient.urlLoading(mockWebView, 'https://google.com');
        verify(mockCallbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: true,
        ));
        verify(mockWebView.loadUrl('https://google.com', <String, String>{}));
      });

      testWidgets('onNavigationRequest from requestLoading',
          (WidgetTester tester) async {
        await buildWidget(tester, hasNavigationDelegate: true);
        when(mockCallbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isTrue, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        webViewClient.requestLoading(
          mockWebView,
          android_webview.WebResourceRequest(
            url: 'https://google.com',
            isForMainFrame: true,
            isRedirect: false,
            hasGesture: false,
            method: 'POST',
            requestHeaders: <String, String>{},
          ),
        );
        verify(mockCallbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: true,
        ));
        verify(mockWebView.loadUrl('https://google.com', <String, String>{}));
      });

      group('$JavascriptChannelRegistry', () {
        testWidgets('onJavascriptChannelMessage', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.addJavascriptChannels(<String>{'hello'});

          final WebViewAndroidJavaScriptChannel javaScriptChannel =
              verify(mockWebView.addJavaScriptChannel(captureAny))
                  .captured
                  .single as WebViewAndroidJavaScriptChannel;
          javaScriptChannel.postMessage('goodbye');
          verify(mockJavascriptChannelRegistry.onJavascriptChannelMessage(
            'hello',
            'goodbye',
          ));
        });
      });
    });
  });
}

class _EqualsHttpRequest extends Matcher {
  const _EqualsHttpRequest(this._expected);

  final http.Request _expected;

  @override
  bool matches(
      covariant http.Request actual, Map<dynamic, dynamic> matchState) {
    return equals(_expected.url).matches(actual.url, matchState) &&
        equals(_expected.headers).matches(actual.headers, matchState) &&
        equals(_expected.method).matches(actual.method, matchState) &&
        equals(_expected.bodyBytes).matches(actual.bodyBytes, matchState);
  }

  @override
  Description describe(Description description) => description.add('matches');
}
