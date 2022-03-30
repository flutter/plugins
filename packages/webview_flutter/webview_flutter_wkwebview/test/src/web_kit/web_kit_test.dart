// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.pigeon.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit_api_impls.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit_api_impls.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation_api_impls.dart';

import 'web_kit_test.mocks.dart';
import '../test_web_kit.pigeon.dart';

@GenerateMocks(<Type>[
  WKNavigationDelegate,
  WKScriptMessageHandler,
  WKUIDelegate,
  WKUserContentController,
  WKWebView,
  WKWebViewConfiguration,
  WKWebsiteDataStore,
  TestWKNavigationDelegateHostApi,
  TestWKScriptMessageHandlerHostApi,
  TestWKUIDelegateHostApi,
  TestWKUserContentControllerHostApi,
  TestWKWebViewHostApi,
  TestWKWebViewConfigurationHostApi,
  TestWKWebsiteDataStoreHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKit', () {
    late InstanceManager instanceManager;

    setUp(() {
      instanceManager = InstanceManager();
    });

    group('$WKWebsiteDataStore', () {
      late MockTestWKWebsiteDataStoreHostApi mockPlatformHostApi;

      late WKWebsiteDataStore websiteDataStore;

      final WKWebViewConfiguration webViewConfiguration =
          WKWebViewConfiguration();

      setUp(() {
        mockPlatformHostApi = MockTestWKWebsiteDataStoreHostApi();
        TestWKWebsiteDataStoreHostApi.setup(mockPlatformHostApi);

        instanceManager.tryAddInstance(webViewConfiguration);
        websiteDataStore = WKWebsiteDataStore.fromWebViewConfiguration(
          webViewConfiguration,
          websiteDataStoreHostApi: WKWebsiteDataStoreHostApiImpl(
            instanceManager: instanceManager,
          ),
        );
      });

      test('createFromWebViewConfiguration', () {
        verify(mockPlatformHostApi.createFromWebViewConfiguration(
          instanceManager.getInstanceId(websiteDataStore),
          instanceManager.getInstanceId(webViewConfiguration),
        ));
      });

      test('removeDataOfTypes', () {
        websiteDataStore.removeDataOfTypes(
          <WKWebsiteDataTypes>{WKWebsiteDataTypes.cookies},
          DateTime.fromMillisecondsSinceEpoch(5000),
        );

        final WKWebsiteDataTypesEnumData typeData =
            verify(mockPlatformHostApi.removeDataOfTypes(
          instanceManager.getInstanceId(websiteDataStore),
          captureAny,
          5.0,
        )).captured.single.single as WKWebsiteDataTypesEnumData;

        expect(typeData.value, WKWebsiteDataTypesEnum.cookies);
      });
    });
    //
    // group('$ScrollView', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$ScrollViewHostApiImpl', () {
    //     late MockTestScrollViewHostApi mockPlatformHostApi;
    //
    //     late ScrollView scrollView;
    //     late int scrollViewInstanceId;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestScrollViewHostApi();
    //       TestScrollViewHostApi.setup(mockPlatformHostApi);
    //
    //       ScrollView.api = ScrollViewHostApiImpl(
    //         instanceManager: instanceManager,
    //       );
    //
    //       scrollView = ScrollView();
    //       scrollViewInstanceId = instanceManager.tryAddInstance(scrollView)!;
    //     });
    //
    //     test('contentOffset', () async {
    //       when(mockPlatformHostApi.getContentOffset(scrollViewInstanceId))
    //           .thenReturn(<double>[4.0, 10.0]);
    //       expect(
    //         scrollView.contentOffset,
    //         completion(const Point<double>(4.0, 10.0)),
    //       );
    //
    //       scrollView.contentOffset = const Point<double>(6.0, 11.0);
    //       await untilCalled(mockPlatformHostApi.setContentOffset(
    //         scrollViewInstanceId,
    //         6.0,
    //         11.0,
    //       ));
    //     });
    //   });
    //
    group('$WKScriptMessageHandler', () {
      late MockTestWKScriptMessageHandlerHostApi mockPlatformHostApi;

      late WKScriptMessageHandler scriptMessageHandler;

      setUp(() async {
        mockPlatformHostApi = MockTestWKScriptMessageHandlerHostApi();
        TestWKScriptMessageHandlerHostApi.setup(mockPlatformHostApi);

        scriptMessageHandler = WKScriptMessageHandler(
          scriptMessengerApi: WKScriptMessageHandlerHostApiImpl(
            instanceManager: instanceManager,
          ),
        );

        await scriptMessageHandler.scriptMessengerApi
            .createFromInstance(scriptMessageHandler);
      });

      test('create', () async {
        verify(mockPlatformHostApi.create(
          instanceManager.getInstanceId(scriptMessageHandler),
        ));
      });
    });

    group('$WKUserContentController', () {
      late MockTestWKUserContentControllerHostApi mockPlatformHostApi;

      late WKUserContentController userContentController;

      final WKWebViewConfiguration webViewConfiguration =
          WKWebViewConfiguration();

      setUp(() {
        mockPlatformHostApi = MockTestWKUserContentControllerHostApi();
        TestWKUserContentControllerHostApi.setup(mockPlatformHostApi);

        instanceManager.tryAddInstance(webViewConfiguration);
        userContentController =
            WKUserContentController.fromWebViewConfiguretion(
          webViewConfiguration,
          userContentControllerApi: WKUserContentControllerHostApiImpl(
            instanceManager: instanceManager,
          ),
        );
      });

      test('createFromWebViewConfiguration', () async {
        verify(mockPlatformHostApi.createFromWebViewConfiguration(
          instanceManager.getInstanceId(userContentController),
          instanceManager.getInstanceId(webViewConfiguration),
        ));
      });

      test('addScriptMessageHandler', () async {
        final WKScriptMessageHandler handler = MockWKScriptMessageHandler();
        instanceManager.tryAddInstance(handler);

        userContentController.addScriptMessageHandler(handler, 'handlerName');
        verify(mockPlatformHostApi.addScriptMessageHandler(
          instanceManager.getInstanceId(userContentController),
          instanceManager.getInstanceId(handler),
          'handlerName',
        ));
      });

      test('removeScriptMessageHandler', () async {
        userContentController.removeScriptMessageHandler('handlerName');
        verify(mockPlatformHostApi.removeScriptMessageHandler(
          instanceManager.getInstanceId(userContentController),
          'handlerName',
        ));
      });

      test('removeAllScriptMessageHandlers', () async {
        userContentController.removeAllScriptMessageHandlers();
        verify(mockPlatformHostApi.removeAllScriptMessageHandlers(
          instanceManager.getInstanceId(userContentController),
        ));
      });

      test('addUserScript', () {
        userContentController.addUserScript(const WKUserScript(
          'aScript',
          WKUserScriptInjectionTime.atDocumentEnd,
          isMainFrameOnly: false,
        ));
        verify(mockPlatformHostApi.addUserScript(
          instanceManager.getInstanceId(userContentController),
          argThat(isA<WKUserScriptData>()),
        ));
      });

      test('removeAllUserScripts', () {
        userContentController.removeAllUserScripts();
        verify(mockPlatformHostApi.removeAllUserScripts(
          instanceManager.getInstanceId(userContentController),
        ));
      });
    });

    group('$WKWebViewConfiguration', () {
      late MockTestWKWebViewConfigurationHostApi mockPlatformHostApi;

      late WKWebViewConfiguration webViewConfiguration;

      setUp(() async {
        mockPlatformHostApi = MockTestWKWebViewConfigurationHostApi();
        TestWKWebViewConfigurationHostApi.setup(mockPlatformHostApi);

        webViewConfiguration = WKWebViewConfiguration(
          webViewConfigurationApi: WKWebViewConfigurationHostApiImpl(
            instanceManager: instanceManager,
          ),
        );

        await webViewConfiguration.webViewConfigurationApi
            .createFromInstance(webViewConfiguration);
      });

      test('create', () async {
        verify(
          mockPlatformHostApi.create(instanceManager.getInstanceId(
            webViewConfiguration,
          )),
        );
      });

      test('createFromWebView', () async {
        TestWKWebViewHostApi.setup(MockTestWKWebViewHostApi());

        final WKWebView webView = WKWebView(
          webViewConfiguration,
          webviewHostApi: WKWebViewHostApiImpl(
            instanceManager: instanceManager,
          ),
        );

        final WKWebViewConfiguration configurationFromWebView =
            webView.configuration;
        verify(mockPlatformHostApi.createFromWebView(
          instanceManager.getInstanceId(configurationFromWebView)!,
          instanceManager.getInstanceId(webView)!,
        ));
      });

      test('allowsInlineMediaPlayback', () {
        webViewConfiguration.setAllowsInlineMediaPlayback(true);
        verify(mockPlatformHostApi.setAllowsInlineMediaPlayback(
          instanceManager.getInstanceId(webViewConfiguration),
          true,
        ));
      });

      test('mediaTypesRequiringUserActionForPlayback', () {
        webViewConfiguration.setMediaTypesRequiringUserActionForPlayback(
          <WKAudiovisualMediaType>{
            WKAudiovisualMediaType.audio,
            WKAudiovisualMediaType.video,
          },
        );

        final List<WKAudiovisualMediaTypeEnumData?> typeData = verify(
            mockPlatformHostApi.setMediaTypesRequiringUserActionForPlayback(
          instanceManager.getInstanceId(webViewConfiguration),
          captureAny,
        )).captured.single as List<WKAudiovisualMediaTypeEnumData?>;

        expect(typeData, hasLength(2));
        expect(typeData[0]!.value, WKAudiovisualMediaTypeEnum.audio);
        expect(typeData[1]!.value, WKAudiovisualMediaTypeEnum.video);
      });
    });

    group('$WKNavigationDelegate', () {
      late MockTestWKNavigationDelegateHostApi mockPlatformHostApi;

      late WKNavigationDelegate navigationDelegate;

      setUp(() async {
        mockPlatformHostApi = MockTestWKNavigationDelegateHostApi();
        TestWKNavigationDelegateHostApi.setup(mockPlatformHostApi);

        navigationDelegate = WKNavigationDelegate(
          navigationDelegateApi: WKNavigationDelegateHostApiImpl(
            instanceManager: instanceManager,
          ),
        );

        await navigationDelegate.navigationDelegateApi
            .createFromInstance(navigationDelegate);
      });

      test('create', () async {
        verify(mockPlatformHostApi.create(
          instanceManager.getInstanceId(navigationDelegate),
        ));
      });
    });

    group('$WKWebView', () {
      late MockTestWKWebViewHostApi mockPlatformHostApi;

      late WKWebViewConfiguration webViewConfiguration;

      late WKWebView webView;
      late int webViewInstanceId;

      setUp(() {
        mockPlatformHostApi = MockTestWKWebViewHostApi();
        TestWKWebViewHostApi.setup(mockPlatformHostApi);

        webViewConfiguration = WKWebViewConfiguration();
        instanceManager.tryAddInstance(webViewConfiguration);

        webView = WKWebView(
          webViewConfiguration,
          webviewHostApi: WKWebViewHostApiImpl(
            instanceManager: instanceManager,
          ),
        );
        webViewInstanceId = instanceManager.getInstanceId(webView)!;
      });

      test('create', () async {
        verify(mockPlatformHostApi.create(
          instanceManager.getInstanceId(webView),
          instanceManager.getInstanceId(
            webViewConfiguration,
          ),
        ));
      });

      test('setUIDelegate', () async {
        final WKUIDelegate uiDelegate = WKUIDelegate();
        instanceManager.tryAddInstance(uiDelegate)!;

        await webView.setUIDelegate(uiDelegate);
        verify(mockPlatformHostApi.setUIDelegate(
          webViewInstanceId,
          instanceManager.getInstanceId(uiDelegate),
        ));
      });

      test('setNavigationDelegate', () async {
        final WKNavigationDelegate navigationDelegate = WKNavigationDelegate();
        instanceManager.tryAddInstance(navigationDelegate)!;

        await webView.setNavigationDelegate(navigationDelegate);
        verify(mockPlatformHostApi.setNavigationDelegate(
          webViewInstanceId,
          instanceManager.getInstanceId(navigationDelegate),
        ));
      });

      test('getUrl', () {
        when(
          mockPlatformHostApi.getUrl(webViewInstanceId),
        ).thenReturn('www.flutter.dev');
        expect(webView.getUrl(), completion('www.flutter.dev'));
      });

      test('getEstimatedProgress', () {
        when(
          mockPlatformHostApi.getEstimatedProgress(webViewInstanceId),
        ).thenReturn(54.5);
        expect(webView.getEstimatedProgress(), completion(54.5));
      });

      test('loadRequest', () {
        webView.loadRequest(const NSUrlRequest(url: 'www.flutter.dev'));
        verify(mockPlatformHostApi.loadRequest(
          webViewInstanceId,
          argThat(isA<NSUrlRequestData>()),
        ));
      });

      test('loadHtmlString', () {
        webView.loadHtmlString('a', baseUrl: 'b');
        verify(mockPlatformHostApi.loadHtmlString(webViewInstanceId, 'a', 'b'));
      });

      test('loadFileUrl', () {
        webView.loadFileUrl('a', readAccessUrl: 'b');
        verify(mockPlatformHostApi.loadFileUrl(webViewInstanceId, 'a', 'b'));
      });

      test('loadFlutterAsset', () {
        webView.loadFlutterAsset('a');
        verify(mockPlatformHostApi.loadFlutterAsset(webViewInstanceId, 'a'));
      });

      test('canGoBack', () {
        when(mockPlatformHostApi.canGoBack(webViewInstanceId)).thenReturn(true);
        expect(webView.canGoBack(), completion(isTrue));
      });

      test('canGoForward', () {
        when(mockPlatformHostApi.canGoForward(webViewInstanceId))
            .thenReturn(false);
        expect(webView.canGoForward(), completion(isFalse));
      });

      test('goBack', () {
        webView.goBack();
        verify(mockPlatformHostApi.goBack(webViewInstanceId));
      });

      test('goForward', () {
        webView.goForward();
        verify(mockPlatformHostApi.goForward(webViewInstanceId));
      });

      test('reload', () {
        webView.reload();
        verify(mockPlatformHostApi.reload(webViewInstanceId));
      });

      test('getTitle', () {
        when(mockPlatformHostApi.getTitle(webViewInstanceId))
            .thenReturn('MyTitle');
        expect(webView.getTitle(), completion('MyTitle'));
      });

      test('setAllowsBackForwardNavigationGestures', () {
        webView.setAllowsBackForwardNavigationGestures(false);
        verify(mockPlatformHostApi.setAllowsBackForwardNavigationGestures(
          webViewInstanceId,
          false,
        ));
      });

      test('customUserAgent', () {
        webView.setCustomUserAgent('hello');
        verify(mockPlatformHostApi.setCustomUserAgent(
          webViewInstanceId,
          'hello',
        ));
      });

      test('evaluateJavaScript', () {
        when(mockPlatformHostApi.evaluateJavaScript(webViewInstanceId, 'gogo'))
            .thenAnswer((_) => Future<String>.value('stopstop'));
        expect(webView.evaluateJavaScript('gogo'), completion('stopstop'));
      });
    });
    //
    // group('$FoundationObject', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$FoundationObjectHostApiImpl', () {
    //     late MockTestFoundationObjectHostApi mockPlatformHostApi;
    //
    //     late FoundationObject foundationObject;
    //     late int foundationObjectInstanceId;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestFoundationObjectHostApi();
    //       TestFoundationObjectHostApi.setup(mockPlatformHostApi);
    //       FoundationObject.api =
    //           FoundationObjectHostApiImpl(instanceManager: instanceManager);
    //
    //       foundationObject = FoundationObject();
    //       foundationObjectInstanceId =
    //       instanceManager.tryAddInstance(foundationObject)!;
    //     });
    //
    //     test('addObserver', () async {
    //       foundationObject.addObserver(
    //         foundationObject,
    //         'keyPath',
    //         <KeyValueObservingOptions>{
    //           KeyValueObservingOptions.initial,
    //           KeyValueObservingOptions.prior,
    //         },
    //       );
    //       verify(mockPlatformHostApi.addObserver(
    //         foundationObjectInstanceId,
    //         foundationObjectInstanceId,
    //         'keyPath',
    //         0x04 | 0x08,
    //       ));
    //     });
    //
    //     test('removeObserver', () async {
    //       foundationObject.addObserver(
    //         foundationObject,
    //         'keyPath',
    //         <KeyValueObservingOptions>{
    //           KeyValueObservingOptions.initial,
    //           KeyValueObservingOptions.prior,
    //         },
    //       );
    //       verify(mockPlatformHostApi.addObserver(
    //         foundationObjectInstanceId,
    //         foundationObjectInstanceId,
    //         'keyPath',
    //         0x04 | 0x08,
    //       ));
    //     });
    //   });
    //
    //   group('$FoundationObjectFlutterApiImpl', () {
    //     late FoundationObjectFlutterApiImpl flutterApi;
    //
    //     late MockFoundationObject mockFoundationObject;
    //     late int foundationObjectInstanceId;
    //
    //     setUp(() {
    //       flutterApi =
    //           FoundationObjectFlutterApiImpl(instanceManager: instanceManager);
    //       mockFoundationObject = MockFoundationObject();
    //       instanceManager.tryAddInstance(mockFoundationObject);
    //       foundationObjectInstanceId =
    //       instanceManager.getInstanceId(mockFoundationObject)!;
    //     });
    //
    //     test('observeValue', () {
    //       final FoundationObject mockObserver = MockFoundationObject();
    //       final int mockObserverInstanceId =
    //       instanceManager.tryAddInstance(mockObserver)!;
    //
    //       flutterApi.observeValue(
    //         foundationObjectInstanceId,
    //         'aKeyPath',
    //         mockObserverInstanceId,
    //         <String, Object?>{
    //           'kind': 'setting',
    //           'new': 23,
    //           'old': 45,
    //           'notificationIsPrior': false,
    //         },
    //       );
    //       verify(mockFoundationObject.observeValue(
    //         'aKeyPath',
    //         mockObserver,
    //         <KeyValueChangeKey, Object?>{
    //           KeyValueChangeKey.kind: KeyValueChange.setting,
    //           KeyValueChangeKey.new_: 23,
    //           KeyValueChangeKey.old: 45,
    //           KeyValueChangeKey.notificationIsPrior: false,
    //         },
    //       ));
    //     });
    //   });
    // });
    //

    group('$WKUIDelegate', () {
      late MockTestWKUIDelegateHostApi mockPlatformHostApi;

      late WKUIDelegate uiDelegate;

      setUp(() async {
        mockPlatformHostApi = MockTestWKUIDelegateHostApi();
        TestWKUIDelegateHostApi.setup(mockPlatformHostApi);

        uiDelegate = WKUIDelegate(
          uiDelegateApi: WKUIDelegateHostApiImpl(
            instanceManager: instanceManager,
          ),
        );

        await uiDelegate.uiDelegateApi.createFromInstance(uiDelegate);
      });

      test('create', () async {
        verify(mockPlatformHostApi.create(
          instanceManager.getInstanceId(uiDelegate),
        ));
      });
    });
  });
}
