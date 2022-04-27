// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit_webview_widget.dart';

import 'web_kit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  UIScrollView,
  WKNavigationDelegate,
  WKPreferences,
  WKScriptMessageHandler,
  WKWebView,
  WKWebViewConfiguration,
  WKWebsiteDataStore,
  WKUIDelegate,
  WKUserContentController,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewWidgetProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewWidget', () {
    late MockWKWebView mockWebView;
    late MockWebViewWidgetProxy mockWebViewWidgetProxy;
    late MockWKUserContentController mockUserContentController;
    late MockWKPreferences mockPreferences;
    late MockWKWebViewConfiguration mockWebViewConfiguration;
    late MockWKUIDelegate mockUIDelegate;
    late MockUIScrollView mockScrollView;
    late MockWKWebsiteDataStore mockWebsiteDataStore;
    late MockWKNavigationDelegate mockNavigationDelegate;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    late WebKitWebViewPlatformController testController;

    setUp(() {
      mockWebView = MockWKWebView();
      mockWebViewConfiguration = MockWKWebViewConfiguration();
      mockUserContentController = MockWKUserContentController();
      mockPreferences = MockWKPreferences();
      mockUIDelegate = MockWKUIDelegate();
      mockScrollView = MockUIScrollView();
      mockWebsiteDataStore = MockWKWebsiteDataStore();
      mockNavigationDelegate = MockWKNavigationDelegate();
      mockWebViewWidgetProxy = MockWebViewWidgetProxy();

      when(mockWebViewWidgetProxy.createWebView(any)).thenReturn(mockWebView);
      when(mockWebViewWidgetProxy.createUIDelgate()).thenReturn(mockUIDelegate);
      when(mockWebViewWidgetProxy.createNavigationDelegate())
          .thenReturn(mockNavigationDelegate);
      when(mockWebView.configuration).thenReturn(mockWebViewConfiguration);
      when(mockWebViewConfiguration.userContentController).thenReturn(
        mockUserContentController,
      );
      when(mockWebViewConfiguration.preferences).thenReturn(mockPreferences);

      when(mockWebView.scrollView).thenReturn(mockScrollView);

      when(mockWebViewConfiguration.websiteDataStore).thenReturn(
        mockWebsiteDataStore,
      );

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();
      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();
    });

    // Builds a WebViewCupertinoWidget with default parameters.
    Future<void> buildWidget(
      WidgetTester tester, {
      CreationParams? creationParams,
      bool hasNavigationDelegate = false,
      bool hasProgressTracking = false,
    }) async {
      await tester.pumpWidget(WebKitWebViewWidget(
        creationParams: creationParams ??
            CreationParams(
                webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: hasNavigationDelegate,
              hasProgressTracking: hasProgressTracking,
            )),
        callbacksHandler: mockCallbacksHandler,
        javascriptChannelRegistry: mockJavascriptChannelRegistry,
        webViewProxy: mockWebViewWidgetProxy,
        configuration: mockWebViewConfiguration,
        onBuildWidget: (WebKitWebViewPlatformController controller) {
          testController = controller;
          return Container();
        },
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('build $WebKitWebViewWidget', (WidgetTester tester) async {
      await buildWidget(tester);
    });

    testWidgets('Requests to open a new window loads request in same window',
        (WidgetTester tester) async {
      await buildWidget(tester);

      final dynamic onCreateWebView =
          verify(mockUIDelegate.setOnCreateWebView(captureAny)).captured.single
              as void Function(WKWebViewConfiguration, WKNavigationAction);

      const NSUrlRequest request = NSUrlRequest(url: 'https://google.com');
      onCreateWebView(
        mockWebViewConfiguration,
        const WKNavigationAction(
          request: request,
          targetFrame: WKFrameInfo(isMainFrame: false),
        ),
      );

      verify(mockWebView.loadRequest(request));
    });

    group('CreationParams', () {
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
        final NSUrlRequest request = verify(mockWebView.loadRequest(captureAny))
            .captured
            .single as NSUrlRequest;
        expect(request.url, 'https://www.google.com');
      });

      testWidgets('backgroundColor', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            backgroundColor: Colors.red,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebView.setOpaque(false));
        verify(mockWebView.setBackgroundColor(Colors.transparent));
        verify(mockScrollView.setBackgroundColor(Colors.red));
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

        verify(mockWebView.setCustomUserAgent('MyUserAgent'));
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

        verify(mockWebViewConfiguration
            .setMediaTypesRequiringUserActionForPlayback(<
                WKAudiovisualMediaType>{
          WKAudiovisualMediaType.all,
        }));
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

        verify(mockWebViewConfiguration
            .setMediaTypesRequiringUserActionForPlayback(<
                WKAudiovisualMediaType>{
          WKAudiovisualMediaType.none,
        }));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

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

        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
            captureAny,
            captureAny,
          ),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'a');
        expect(
          javaScriptChannels[2],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'b');
      });

      group('WebSettings', () {
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

          verify(mockPreferences.setJavaScriptEnabled(true));
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

          verify(mockNavigationDelegate
              .setDecidePolicyForNavigationAction(argThat(isNotNull)));
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

          verify(mockWebView.setCustomUserAgent('myUserAgent'));
        });

        testWidgets(
          'enabling zoom re-adds JavaScript channels',
          (WidgetTester tester) async {
            when(mockWebViewWidgetProxy.createScriptMessageHandler())
                .thenReturn(
              MockWKScriptMessageHandler(),
            );

            await buildWidget(
              tester,
              creationParams: CreationParams(
                webSettings: WebSettings(
                  userAgent: const WebSetting<String?>.absent(),
                  zoomEnabled: false,
                  hasNavigationDelegate: false,
                ),
                javascriptChannelNames: <String>{'myChannel'},
              ),
            );

            clearInteractions(mockUserContentController);

            await testController.updateSettings(WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              zoomEnabled: true,
            ));

            final List<dynamic> javaScriptChannels = verifyInOrder(<Object>[
              mockUserContentController.removeAllUserScripts(),
              mockUserContentController.removeAllScriptMessageHandlers(),
              mockUserContentController.addScriptMessageHandler(
                captureAny,
                captureAny,
              ),
            ]).captured[2];

            expect(
              javaScriptChannels[0],
              isA<WKScriptMessageHandler>(),
            );
            expect(javaScriptChannels[1], 'myChannel');
          },
        );

        testWidgets(
          'enabling zoom removes script',
          (WidgetTester tester) async {
            when(mockWebViewWidgetProxy.createScriptMessageHandler())
                .thenReturn(
              MockWKScriptMessageHandler(),
            );

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

            clearInteractions(mockUserContentController);

            await testController.updateSettings(WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              zoomEnabled: true,
            ));

            verify(mockUserContentController.removeAllUserScripts());
            verify(mockUserContentController.removeAllScriptMessageHandlers());
            verifyNever(mockUserContentController.addScriptMessageHandler(
              any,
              any,
            ));
          },
        );

        testWidgets('zoomEnabled is false', (WidgetTester tester) async {
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

          final WKUserScript zoomScript =
              verify(mockUserContentController.addUserScript(captureAny))
                  .captured
                  .first as WKUserScript;
          expect(zoomScript.isMainFrameOnly, isTrue);
          expect(zoomScript.injectionTime,
              WKUserScriptInjectionTime.atDocumentEnd);
          expect(
            zoomScript.source,
            "var meta = document.createElement('meta');"
            "meta.name = 'viewport';"
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0,"
            "user-scalable=no';"
            "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
          );
        });

        testWidgets('allowsInlineMediaPlayback', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                allowsInlineMediaPlayback: true,
              ),
            ),
          );

          verify(mockWebViewConfiguration.setAllowsInlineMediaPlayback(true));
        });
      });
    });

    group('WebKitWebViewPlatformController', () {
      testWidgets('loadFile', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFile('/path/to/file.html');
        verify(mockWebView.loadFileUrl(
          '/path/to/file.html',
          readAccessUrl: '/path/to',
        ));
      });

      testWidgets('loadFlutterAsset', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFlutterAsset('test_assets/index.html');
        verify(mockWebView.loadFlutterAsset('test_assets/index.html'));
      });

      testWidgets('loadHtmlString', (WidgetTester tester) async {
        await buildWidget(tester);

        const String htmlString = '<html><body>Test data.</body></html>';
        await testController.loadHtmlString(htmlString, baseUrl: 'baseUrl');

        verify(mockWebView.loadHtmlString(
          '<html><body>Test data.</body></html>',
          baseUrl: 'baseUrl',
        ));
      });

      testWidgets('loadUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        final NSUrlRequest request = verify(mockWebView.loadRequest(captureAny))
            .captured
            .single as NSUrlRequest;
        expect(request.url, 'https://www.google.com');
        expect(request.allHttpHeaderFields, <String, String>{'a': 'header'});
      });

      group('loadRequest', () {
        testWidgets('Throws ArgumentError for empty scheme',
            (WidgetTester tester) async {
          await buildWidget(tester);

          expect(
              () async => await testController.loadRequest(
                    WebViewRequest(
                      uri: Uri.parse('www.google.com'),
                      method: WebViewRequestMethod.get,
                    ),
                  ),
              throwsA(const TypeMatcher<ArgumentError>()));
        });

        testWidgets('GET without headers', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
          ));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.allHttpHeaderFields, <String, String>{});
          expect(request.httpMethod, 'get');
        });

        testWidgets('GET with headers', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
            headers: <String, String>{'a': 'header'},
          ));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.allHttpHeaderFields, <String, String>{'a': 'header'});
          expect(request.httpMethod, 'get');
        });

        testWidgets('POST without body', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.post,
          ));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
        });

        testWidgets('POST with body', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
              uri: Uri.parse('https://www.google.com'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('Test Body'.codeUnits)));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
          expect(
            request.httpBody,
            Uint8List.fromList('Test Body'.codeUnits),
          );
        });
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

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('evaluateJavascript with null return value',
          (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies null
        // is represented the way it is in Objective-C.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('(null)'),
        );
      });

      testWidgets('evaluateJavascript with list return value',
          (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(<Object?>[1, 'string', null]),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies list
        // is represented the way it is in Objective-C.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('(1,string,"<null>")'),
        );
      });

      testWidgets('evaluateJavascript with map return value',
          (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(<Object?, Object?>{
            1: 'string',
            null: null,
          }),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies map
        // is represented the way it is in Objective-C.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('{1 = string;"<null>" = "<null>"}'),
        );
      });

      testWidgets('evaluateJavascript throws exception',
          (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript'))
            .thenThrow(Error());
        expect(
          testController.evaluateJavascript('runJavaScript'),
          throwsA(isA<Error>()),
        );
      });

      testWidgets('runJavascriptReturningResult', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascriptReturningResult('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets(
          'runJavascriptReturningResult throws error on null return value',
          (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String?>.value(null),
        );
        expect(
          () => testController.runJavascriptReturningResult('runJavaScript'),
          throwsArgumentError,
        );
      });

      testWidgets('runJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets(
          'runJavascript ignores exception with unsupported javascript type',
          (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript'))
            .thenThrow(PlatformException(
          code: '',
          details: const NSError(
            code: WKErrorCode.javaScriptResultTypeIsUnsupported,
            domain: '',
            localizedDescription: '',
          ),
        ));
        expect(
          testController.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getTitle())
            .thenAnswer((_) => Future<String>.value('Web Title'));
        expect(testController.getTitle(), completion('Web Title'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollTo(2, 4);
        verify(mockScrollView.setContentOffset(const Point<double>(2.0, 4.0)));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollBy(2, 4);
        verify(mockScrollView.scrollBy(const Point<double>(2.0, 4.0)));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockScrollView.getContentOffset()).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        expect(testController.getScrollX(), completion(8.0));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        await buildWidget(tester);

        await buildWidget(tester);

        when(mockScrollView.getContentOffset()).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        expect(testController.getScrollY(), completion(16.0));
      });

      testWidgets('clearCache', (WidgetTester tester) async {
        await buildWidget(tester);
        when(
          mockWebsiteDataStore.removeDataOfTypes(
            <WKWebsiteDataTypes>{
              WKWebsiteDataTypes.memoryCache,
              WKWebsiteDataTypes.diskCache,
              WKWebsiteDataTypes.offlineWebApplicationCache,
              WKWebsiteDataTypes.localStroage,
            },
            DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ).thenAnswer((_) => Future<bool>.value(false));

        expect(testController.clearCache(), completes);
      });

      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
              captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'c');
        expect(
          javaScriptChannels[2],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'd');

        final List<WKUserScript> userScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .cast<WKUserScript>();
        expect(userScripts[0].source, 'window.c = webkit.messageHandlers.c;');
        expect(
          userScripts[0].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
        expect(userScripts[1].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[1].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        reset(mockUserContentController);

        await testController.removeJavascriptChannels(<String>{'c'});

        verify(mockUserContentController.removeAllScriptMessageHandlers());
        verify(mockUserContentController.removeAllUserScripts());

        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
              captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'd');

        final List<WKUserScript> userScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .cast<WKUserScript>();
        expect(userScripts[0].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[0].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
      });

      testWidgets('removeJavascriptChannels with zoom disabled',
          (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

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

        await testController.addJavascriptChannels(<String>{'c'});
        clearInteractions(mockUserContentController);
        await testController.removeJavascriptChannels(<String>{'c'});

        final WKUserScript zoomScript =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .first as WKUserScript;
        expect(zoomScript.isMainFrameOnly, isTrue);
        expect(
            zoomScript.injectionTime, WKUserScriptInjectionTime.atDocumentEnd);
        expect(
          zoomScript.source,
          "var meta = document.createElement('meta');"
          "meta.name = 'viewport';"
          "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0,"
          "user-scalable=no';"
          "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
        );
      });
    });

    group('WebViewPlatformCallbacksHandler', () {
      testWidgets('onPageStarted', (WidgetTester tester) async {
        await buildWidget(tester);

        final dynamic didStartProvisionalNavigation = verify(
                mockNavigationDelegate
                    .setDidStartProvisionalNavigation(captureAny))
            .captured
            .single as void Function(WKWebView, String);
        didStartProvisionalNavigation(mockWebView, 'https://google.com');

        verify(mockCallbacksHandler.onPageStarted('https://google.com'));
      });

      testWidgets('onPageFinished', (WidgetTester tester) async {
        await buildWidget(tester);

        final dynamic didFinishNavigation =
            verify(mockNavigationDelegate.setDidFinishNavigation(captureAny))
                .captured
                .single as void Function(WKWebView, String);
        didFinishNavigation(mockWebView, 'https://google.com');

        verify(mockCallbacksHandler.onPageFinished('https://google.com'));
      });

      testWidgets('onWebResourceError from didFailNavigation',
          (WidgetTester tester) async {
        await buildWidget(tester);

        final dynamic didFailNavigation =
            verify(mockNavigationDelegate.setDidFailNavigation(captureAny))
                .captured
                .single as void Function(WKWebView, NSError);

        didFailNavigation(
          mockWebView,
          const NSError(
            code: WKErrorCode.webViewInvalidated,
            domain: 'domain',
            localizedDescription: 'my desc',
          ),
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'my desc');
        expect(error.errorCode, WKErrorCode.webViewInvalidated);
        expect(error.domain, 'domain');
        expect(error.errorType, WebResourceErrorType.webViewInvalidated);
      });

      testWidgets('onWebResourceError from didFailProvisionalNavigation',
          (WidgetTester tester) async {
        await buildWidget(tester);

        final dynamic didFailProvisionalNavigation = verify(
                mockNavigationDelegate
                    .setDidFailProvisionalNavigation(captureAny))
            .captured
            .single as void Function(WKWebView, NSError);

        didFailProvisionalNavigation(
          mockWebView,
          const NSError(
            code: WKErrorCode.webContentProcessTerminated,
            domain: 'domain',
            localizedDescription: 'my desc',
          ),
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'my desc');
        expect(error.errorCode, WKErrorCode.webContentProcessTerminated);
        expect(error.domain, 'domain');
        expect(
          error.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
      });

      testWidgets(
          'onWebResourceError from webViewWebContentProcessDidTerminate',
          (WidgetTester tester) async {
        await buildWidget(tester);

        final dynamic webViewWebContentProcessDidTerminate = verify(
                mockNavigationDelegate
                    .setWebViewWebContentProcessDidTerminate(captureAny))
            .captured
            .single as void Function(WKWebView);
        webViewWebContentProcessDidTerminate(mockWebView);

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, '');
        expect(error.errorCode, WKErrorCode.webContentProcessTerminated);
        expect(error.domain, 'WKErrorDomain');
        expect(
          error.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
      });

      testWidgets('onNavigationRequest from decidePolicyForNavigationAction',
          (WidgetTester tester) async {
        await buildWidget(tester, hasNavigationDelegate: true);

        final dynamic decidePolicyForNavigationAction = verify(
                    mockNavigationDelegate
                        .setDecidePolicyForNavigationAction(captureAny))
                .captured
                .single
            as Future<WKNavigationActionPolicy> Function(
                WKWebView, WKNavigationAction);

        when(mockCallbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isFalse, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        expect(
          decidePolicyForNavigationAction(
            mockWebView,
            const WKNavigationAction(
              request: NSUrlRequest(url: 'https://google.com'),
              targetFrame: WKFrameInfo(isMainFrame: false),
            ),
          ),
          completion(WKNavigationActionPolicy.allow),
        );

        verify(mockCallbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: false,
        ));
      });

      testWidgets('onProgress', (WidgetTester tester) async {
        await buildWidget(tester, hasProgressTracking: true);
        final dynamic observeValue =
            verify(mockWebView.setObserveValue(captureAny)).captured.single
                as void Function(
          String keyPath,
          NSObject object,
          Map<NSKeyValueChangeKey, Object?> change,
        );

        verify(mockWebView.addObserver(
          mockWebView,
          keyPath: 'estimatedProgress',
          options: <NSKeyValueObservingOptions>{
            NSKeyValueObservingOptions.newValue,
          },
        ));

        observeValue(
          'estimatedProgress',
          mockWebView,
          <NSKeyValueChangeKey, Object?>{NSKeyValueChangeKey.newValue: 0.32},
        );

        verify(mockCallbacksHandler.onProgress(32));
      });
    });

    group('JavascriptChannelRegistry', () {
      testWidgets('onJavascriptChannelMessage', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(tester);
        await testController.addJavascriptChannels(<String>{'hello'});

        final MockWKScriptMessageHandler messageHandler = verify(
                mockUserContentController.addScriptMessageHandler(
                    captureAny, 'hello'))
            .captured
            .single as MockWKScriptMessageHandler;

        final dynamic didReceiveScriptMessage =
            verify(messageHandler.setDidReceiveScriptMessage(captureAny))
                .captured
                .single as void Function(
          WKUserContentController userContentController,
          WKScriptMessage message,
        );

        didReceiveScriptMessage(
          mockUserContentController,
          const WKScriptMessage(name: 'hello', body: 'A message.'),
        );
        verify(mockJavascriptChannelRegistry.onJavascriptChannelMessage(
          'hello',
          'A message.',
        ));
      });
    });
  });
}
