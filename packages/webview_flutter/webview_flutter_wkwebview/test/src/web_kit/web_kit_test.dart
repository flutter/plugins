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
  WKWebsiteDataStore,
  TestWKWebsiteDataStoreHostApi,
  // TestScrollViewHostApi,
  // TestWebSiteDataStoreHostApi,
  // TestPreferencesHostApi,
  // TestScriptMessageHandlerHostApi,
  // TestUserContentControllerHostApi,
  // TestNavigationDelegateHostApi,
  // TestFoundationObjectHostApi,
  // TestWebViewHostApi,
  // TestWebViewConfigurationHostApi,
  // TestIosViewHostApi,
  // TestIosDelegateHostApi,
  // ScriptMessageHandler,
  // NavigationDelegate,
  // FoundationObject,
  // WebView,
  // WebViewConfiguration,
  // IosDelegate,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKit', () {
    late InstanceManager instanceManager;

    setUp(() {
      instanceManager = InstanceManager();
    });

    group('$WKWebsiteDataStore', () {
      final MockTestWKWebsiteDataStoreHostApi mockPlatformHostApi =
          MockTestWKWebsiteDataStoreHostApi();

      final WKWebViewConfiguration webViewConfiguration =
          WKWebViewConfiguration();

      late WKWebsiteDataStore websiteDataStore;
      late int websiteDataStoreInstanceId;

      setUp(() {
        TestWKWebsiteDataStoreHostApi.setup(mockPlatformHostApi);

        instanceManager.tryAddInstance(webViewConfiguration);
        websiteDataStore = WKWebsiteDataStore.fromWebViewConfiguration(
          webViewConfiguration,
          websiteDataStoreHostApi: WKWebsiteDataStoreHostApiImpl(
            instanceManager: instanceManager,
          ),
        );

        websiteDataStoreInstanceId =
            instanceManager.getInstanceId(websiteDataStore)!;
      });

      test('createFromWebViewConfiguration', () {
        verify(mockPlatformHostApi.createFromWebViewConfiguration(
          websiteDataStoreInstanceId,
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
          websiteDataStoreInstanceId,
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
    //   group('$ScrollViewFlutterApiImpl', () {
    //     late ScrollViewFlutterApiImpl flutterApi;
    //
    //     setUp(() {
    //       flutterApi = ScrollViewFlutterApiImpl(
    //         instanceManager: instanceManager,
    //       );
    //     });
    //
    //     test('create', () {
    //       flutterApi.create(0);
    //       expect(instanceManager.getInstance(0)!, isA<ScrollView>());
    //     });
    //   });
    // });
    //
    // group('$Preferences', () {
    //   late MockTestPreferencesHostApi mockPlatformHostApi;
    //   late InstanceManager instanceManager;
    //
    //   late Preferences preferences;
    //   late int preferencesInstanceId;
    //
    //   setUp(() {
    //     mockPlatformHostApi = MockTestPreferencesHostApi();
    //     TestPreferencesHostApi.setup(mockPlatformHostApi);
    //
    //     instanceManager = InstanceManager();
    //     Preferences.api = PreferencesHostApiImpl(
    //       instanceManager: instanceManager,
    //     );
    //
    //     preferences = Preferences();
    //     preferencesInstanceId = instanceManager.tryAddInstance(preferences)!;
    //   });
    //
    //   test('create', () {
    //     final Preferences createdPreferences = Preferences();
    //     Preferences.api.createFromInstance(createdPreferences);
    //     verify(mockPlatformHostApi.create(instanceManager.getInstanceId(
    //       createdPreferences,
    //     )!));
    //   });
    //
    //   test('setJavaScriptEnabled', () async {
    //     preferences.javaScriptEnabled = false;
    //     verify(mockPlatformHostApi.setJavaScriptEnabled(
    //       preferencesInstanceId,
    //       false,
    //     ));
    //   });
    // });
    //
    // group('$ScriptMessageHandler', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$ScriptMessageHandlerHostApiImpl', () {
    //     late MockTestScriptMessageHandlerHostApi mockPlatformHostApi;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestScriptMessageHandlerHostApi();
    //       TestScriptMessageHandlerHostApi.setup(mockPlatformHostApi);
    //
    //       ScriptMessageHandler.api = ScriptMessageHandlerHostApiImpl(
    //         instanceManager: instanceManager,
    //       );
    //     });
    //
    //     test('create', () async {
    //       final ScriptMessageHandler instance = MockScriptMessageHandler();
    //       await ScriptMessageHandler.api.createFromInstance(instance);
    //       expect(instanceManager.getInstance(0), instance);
    //     });
    //   });
    //
    //   group('$ScriptMessageHandlerFlutterApiImpl', () {
    //     late ScriptMessageHandlerFlutterApiImpl flutterApi;
    //
    //     late MockScriptMessageHandler mockScriptMessageHandler;
    //     late int scriptMessageHandlerInstanceId;
    //
    //     setUp(() {
    //       flutterApi = ScriptMessageHandlerFlutterApiImpl(
    //         instanceManager: instanceManager,
    //       );
    //       mockScriptMessageHandler = MockScriptMessageHandler();
    //       instanceManager.tryAddInstance(mockScriptMessageHandler);
    //       scriptMessageHandlerInstanceId =
    //       instanceManager.getInstanceId(mockScriptMessageHandler)!;
    //     });
    //
    //     test('didReceiveScriptMessage', () {
    //       final UserContentController userContentController =
    //       UserContentController();
    //       instanceManager.tryAddInstance(userContentController);
    //       final int userContentControllerInstanceId =
    //       instanceManager.getInstanceId(
    //         userContentController,
    //       )!;
    //
    //       flutterApi.didReceiveScriptMessage(
    //         scriptMessageHandlerInstanceId,
    //         userContentControllerInstanceId,
    //         ScriptMessageData()
    //           ..name = 'myName'
    //           ..body = 'body',
    //       );
    //
    //       verify(mockScriptMessageHandler.didReceiveScriptMessage(
    //           userContentController,
    //           argThat(
    //             isA<ScriptMessage>(),
    //           )));
    //     });
    //   });
    // });
    //
    // group('$UserContentController', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$UserContentControllerHostApiImpl', () {
    //     late MockTestUserContentControllerHostApi mockPlatformHostApi;
    //
    //     late UserContentController userContentController;
    //     late int userContentControllerInstanceId;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestUserContentControllerHostApi();
    //       TestUserContentControllerHostApi.setup(mockPlatformHostApi);
    //       UserContentController.api = UserContentControllerHostApiImpl(
    //           instanceManager: instanceManager);
    //
    //       userContentController = UserContentController();
    //       userContentControllerInstanceId =
    //       instanceManager.tryAddInstance(userContentController)!;
    //     });
    //
    //     test('create', () async {
    //       final InstanceManager createInstanceManager = InstanceManager();
    //       UserContentController.api = UserContentControllerHostApiImpl(
    //         instanceManager: createInstanceManager,
    //       );
    //       final UserContentController instance = UserContentController();
    //       await UserContentController.api.createFromInstance(instance);
    //       expect(createInstanceManager.getInstance(0), instance);
    //     });
    //
    //     test('addScriptMessageHandler', () async {
    //       final ScriptMessageHandler handler = MockScriptMessageHandler();
    //       final int handlerInstanceId =
    //       instanceManager.tryAddInstance(handler)!;
    //
    //       userContentController.addScriptMessageHandler(handler, 'handlerName');
    //       verify(mockPlatformHostApi.addScriptMessageHandler(
    //         userContentControllerInstanceId,
    //         handlerInstanceId,
    //         'handlerName',
    //       ));
    //     });
    //
    //     test('removeScriptMessageHandler', () async {
    //       userContentController.removeScriptMessageHandler('handlerName');
    //       verify(mockPlatformHostApi.removeScriptMessageHandler(
    //         userContentControllerInstanceId,
    //         'handlerName',
    //       ));
    //     });
    //
    //     test('removeAllScriptMessageHandlers', () async {
    //       userContentController.removeAllScriptMessageHandlers();
    //       verify(mockPlatformHostApi.removeAllScriptMessageHandlers(
    //         userContentControllerInstanceId,
    //       ));
    //     });
    //
    //     test('addUserScript', () {
    //       userContentController.addUserScript(UserScript(
    //         'aScript',
    //         UserScriptInjectionTime.atDocumentEnd,
    //         isMainFrameOnly: false,
    //       ));
    //       verify(mockPlatformHostApi.addUserScript(
    //         userContentControllerInstanceId,
    //         argThat(isA<UserScriptData>()),
    //       ));
    //     });
    //
    //     test('removeAllUserScripts', () {
    //       userContentController.removeAllUserScripts();
    //       verify(mockPlatformHostApi.removeAllUserScripts(
    //         userContentControllerInstanceId,
    //       ));
    //     });
    //   });
    // });
    //
    // group('$WebViewConfiguration', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$WebViewConfigurationHostApiImpl', () {
    //     late MockTestWebViewConfigurationHostApi mockPlatformHostApi;
    //
    //     late WebViewConfiguration webViewConfiguration;
    //     late int webViewConfigurationInstanceId;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestWebViewConfigurationHostApi();
    //       TestWebViewConfigurationHostApi.setup(mockPlatformHostApi);
    //       WebViewConfiguration.api =
    //           WebViewConfigurationHostApiImpl(instanceManager: instanceManager);
    //
    //       webViewConfiguration = WebViewConfiguration();
    //       webViewConfigurationInstanceId =
    //       instanceManager.tryAddInstance(webViewConfiguration)!;
    //     });
    //
    //     test('create', () async {
    //       final InstanceManager createInstanceManager = InstanceManager();
    //       WebViewConfiguration.api = WebViewConfigurationHostApiImpl(
    //         instanceManager: createInstanceManager,
    //       );
    //       final WebViewConfiguration instance = WebViewConfiguration();
    //       await WebViewConfiguration.api.createFromInstance(instance);
    //       expect(createInstanceManager.getInstance(0), instance);
    //     });
    //
    //     test('setUserContentController', () {
    //       final UserContentController controller = UserContentController();
    //       final int controllerInstanceId =
    //       instanceManager.tryAddInstance(controller)!;
    //       webViewConfiguration.userContentController = controller;
    //       verify(mockPlatformHostApi.setUserContentController(
    //         webViewConfigurationInstanceId,
    //         controllerInstanceId,
    //       ));
    //     });
    //
    //     test('setPreferences', () {
    //       final Preferences preferences = Preferences();
    //       final int preferencesInstanceId =
    //       instanceManager.tryAddInstance(preferences)!;
    //       webViewConfiguration.preferences = preferences;
    //       verify(mockPlatformHostApi.setPreferences(
    //         webViewConfigurationInstanceId,
    //         preferencesInstanceId,
    //       ));
    //     });
    //
    //     test('allowsInlineMediaPlayback', () {
    //       webViewConfiguration.allowsInlineMediaPlayback = true;
    //       verify(mockPlatformHostApi.setAllowsInlineMediaPlayback(
    //         webViewConfigurationInstanceId,
    //         true,
    //       ));
    //     });
    //
    //     test('mediaTypesRequiringUserActionForPlayback', () {
    //       webViewConfiguration.mediaTypesRequiringUserActionForPlayback =
    //       <AudiovisualMediaType>{
    //         AudiovisualMediaType.audio,
    //         AudiovisualMediaType.video,
    //       };
    //       verify(
    //           mockPlatformHostApi.setMediaTypesRequiringUserActionForPlayback(
    //             webViewConfigurationInstanceId,
    //             1 | 2,
    //           ));
    //     });
    //
    //     test('requiresUserActionForMediaPlayback', () {
    //       webViewConfiguration.requiresUserActionForMediaPlayback = true;
    //       verify(mockPlatformHostApi.setRequiresUserActionForMediaPlayback(
    //         webViewConfigurationInstanceId,
    //         true,
    //       ));
    //     });
    //
    //     test('mediaPlaybackRequiresUserAction', () {
    //       webViewConfiguration.mediaPlaybackRequiresUserAction = false;
    //       verify(mockPlatformHostApi.setMediaPlaybackRequiresUserAction(
    //         webViewConfigurationInstanceId,
    //         false,
    //       ));
    //     });
    //   });
    //
    //   group('$WebViewConfigurationFlutterApiImpl', () {
    //     late WebViewConfigurationFlutterApiImpl flutterApi;
    //
    //     setUp(() {
    //       flutterApi = WebViewConfigurationFlutterApiImpl(
    //         instanceManager: instanceManager,
    //       );
    //     });
    //
    //     test('create', () {
    //       final InstanceManager createInstanceManager = InstanceManager();
    //       flutterApi = WebViewConfigurationFlutterApiImpl(
    //         instanceManager: createInstanceManager,
    //       );
    //       flutterApi.create(0);
    //       expect(
    //         createInstanceManager.getInstance(0)!,
    //         isA<WebViewConfiguration>(),
    //       );
    //     });
    //   });
    // });
    //
    // group('$NavigationDelegate', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$NavigationDelegateHostApiImpl', () {
    //     late MockTestNavigationDelegateHostApi mockPlatformHostApi;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestNavigationDelegateHostApi();
    //       TestNavigationDelegateHostApi.setup(mockPlatformHostApi);
    //       NavigationDelegate.api =
    //           NavigationDelegateHostApiImpl(instanceManager: instanceManager);
    //     });
    //
    //     test('create', () async {
    //       final NavigationDelegate instance = MockNavigationDelegate();
    //       await NavigationDelegate.api.createFromInstance(instance);
    //       expect(instanceManager.getInstance(0), instance);
    //     });
    //   });
    //
    //   group('$NavigationDelegateFlutterApiImpl', () {
    //     late NavigationDelegateFlutterApiImpl flutterApi;
    //
    //     late MockNavigationDelegate mockNavigationDelegate;
    //     late int navigationDelegateInstanceId;
    //
    //     late WebView mockWebView;
    //     late int mockWebViewInstanceId;
    //
    //     setUp(() {
    //       flutterApi = NavigationDelegateFlutterApiImpl(
    //           instanceManager: instanceManager);
    //       mockNavigationDelegate = MockNavigationDelegate();
    //       instanceManager.tryAddInstance(mockNavigationDelegate);
    //       navigationDelegateInstanceId =
    //       instanceManager.getInstanceId(mockNavigationDelegate)!;
    //
    //       mockWebView = MockWebView();
    //       mockWebViewInstanceId = instanceManager.tryAddInstance(mockWebView)!;
    //     });
    //
    //     test('didStartProvisionalNavigation', () {
    //       flutterApi.didStartProvisionalNavigation(
    //         navigationDelegateInstanceId,
    //         mockWebViewInstanceId,
    //       );
    //       verify(
    //         mockNavigationDelegate.didStartProvisionalNavigation(mockWebView),
    //       );
    //     });
    //
    //     test('didFinishNavigation', () {
    //       flutterApi.didFinishNavigation(
    //         navigationDelegateInstanceId,
    //         mockWebViewInstanceId,
    //       );
    //       verify(
    //         mockNavigationDelegate.didFinishNavigation(mockWebView),
    //       );
    //     });
    //
    //     test('decidePolicyForNavigationAction', () {
    //       when(mockNavigationDelegate.decidePolicyForNavigationAction(
    //         mockWebView,
    //         argThat(isA<NavigationAction>()),
    //       )).thenAnswer((_) => Future<NavigationActionPolicy>.value(
    //           NavigationActionPolicy.cancel));
    //
    //       final UrlRequestData urlRequest = UrlRequestData()..url = 'apple';
    //       final FrameInfoData targetFrame = FrameInfoData()
    //         ..isMainFrame = false;
    //       expect(
    //         flutterApi.decidePolicyForNavigationAction(
    //           navigationDelegateInstanceId,
    //           mockWebViewInstanceId,
    //           NavigationActionData()
    //             ..request = urlRequest
    //             ..targetFrame = targetFrame,
    //         ),
    //         completion(1),
    //       );
    //     });
    //
    //     test('didFailNavigation', () {
    //       flutterApi.didFailNavigation(
    //         navigationDelegateInstanceId,
    //         mockWebViewInstanceId,
    //         FoundationErrorData()
    //           ..code = 1
    //           ..domain = 'myDomain'
    //           ..localiziedDescription = 'desc',
    //       );
    //       verify(mockNavigationDelegate.didFailNavigation(
    //         mockWebView,
    //         argThat(isA<FoundationError>()),
    //       ));
    //     });
    //
    //     test('didFailProvisionalNavigation', () {
    //       flutterApi.didFailProvisionalNavigation(
    //         navigationDelegateInstanceId,
    //         mockWebViewInstanceId,
    //         FoundationErrorData()
    //           ..code = 1
    //           ..domain = 'myDomain'
    //           ..localiziedDescription = 'desc',
    //       );
    //       verify(mockNavigationDelegate.didFailProvisionalNavigation(
    //         mockWebView,
    //         argThat(isA<FoundationError>()),
    //       ));
    //     });
    //
    //     test('webViewWebContentProcessDidTerminate', () {
    //       flutterApi.webViewWebContentProcessDidTerminate(
    //         navigationDelegateInstanceId,
    //         mockWebViewInstanceId,
    //       );
    //       verify(
    //         mockNavigationDelegate
    //             .webViewWebContentProcessDidTerminate(mockWebView),
    //       );
    //     });
    //   });
    // });
    //
    // group('$WebView', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$WebViewHostApiImpl', () {
    //     late MockTestWebViewHostApi mockPlatformHostApi;
    //
    //     late WebView webView;
    //     late int webViewInstanceId;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestWebViewHostApi();
    //       TestWebViewHostApi.setup(mockPlatformHostApi);
    //       WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);
    //
    //       webView = WebView();
    //       webViewInstanceId = instanceManager.tryAddInstance(webView)!;
    //     });
    //
    //     test('create', () async {
    //       final InstanceManager createInstanceManager = InstanceManager();
    //       WebView.api = WebViewHostApiImpl(
    //         instanceManager: createInstanceManager,
    //       );
    //
    //       final WebViewConfiguration configuration = WebViewConfiguration();
    //       final WebView instance = WebView(configuration);
    //       createInstanceManager.tryAddInstance(configuration);
    //
    //       await WebView.api.createFromInstance(instance, configuration);
    //       expect(createInstanceManager.getInstance(1), instance);
    //     });
    //
    //     test('scrollView', () {
    //       final ScrollView scrollView = ScrollView();
    //       final int scrollViewInstanceId =
    //       instanceManager.tryAddInstance(scrollView)!;
    //       when(mockPlatformHostApi.getScrollView(any))
    //           .thenReturn(scrollViewInstanceId);
    //
    //       expect(webView.scrollView, completion(scrollView));
    //       // Checks that multiple calls work.
    //       expect(webView.scrollView, completion(scrollView));
    //     });
    //
    //     test('loadRequest', () {
    //       webView.loadRequest(UrlRequest(url: 'www.flutter.dev'));
    //       verify(mockPlatformHostApi.loadRequest(
    //         webViewInstanceId,
    //         argThat(isA<UrlRequestData>()),
    //       ));
    //     });
    //
    //     test('loadHtmlString', () {
    //       webView.loadHtmlString('a', 'string');
    //       verify(mockPlatformHostApi.loadHtmlString(
    //         webViewInstanceId,
    //         'a',
    //         'string',
    //       ));
    //     });
    //
    //     test('loadFileUrl', () {
    //       webView.loadFileUrl('a', 'string');
    //       verify(mockPlatformHostApi.loadFileUrl(
    //         webViewInstanceId,
    //         'a',
    //         'string',
    //       ));
    //     });
    //
    //     test('canGoBack', () {
    //       when(mockPlatformHostApi.canGoBack(webViewInstanceId))
    //           .thenReturn(true);
    //       expect(webView.canGoBack, completion(isTrue));
    //     });
    //
    //     test('canGoForward', () {
    //       when(mockPlatformHostApi.canGoForward(webViewInstanceId))
    //           .thenReturn(false);
    //       expect(webView.canGoForward, completion(isFalse));
    //     });
    //
    //     test('goBack', () {
    //       webView.goBack();
    //       verify(mockPlatformHostApi.goBack(webViewInstanceId));
    //     });
    //
    //     test('goForward', () {
    //       webView.goForward();
    //       verify(mockPlatformHostApi.goForward(webViewInstanceId));
    //     });
    //
    //     test('reload', () {
    //       webView.reload();
    //       verify(mockPlatformHostApi.reload(webViewInstanceId));
    //     });
    //
    //     test('url', () {
    //       when(mockPlatformHostApi.getUrl(webViewInstanceId))
    //           .thenReturn('www.flutter.dev');
    //       expect(webView.url, completion('www.flutter.dev'));
    //     });
    //
    //     test('title', () {
    //       when(mockPlatformHostApi.getTitle(webViewInstanceId))
    //           .thenReturn('MyTitle');
    //       expect(webView.title, completion('MyTitle'));
    //     });
    //
    //     test('estimatedProgress', () {
    //       when(mockPlatformHostApi.getEstimatedProgress(webViewInstanceId))
    //           .thenReturn(54.5);
    //       expect(webView.estimatedProgress, completion(54.5));
    //     });
    //
    //     test('allowsBackForwardNavigationGestures', () {
    //       webView.allowsBackForwardNavigationGestures = false;
    //       verify(mockPlatformHostApi.setAllowsBackForwardNavigationGestures(
    //         webViewInstanceId,
    //         false,
    //       ));
    //     });
    //
    //     test('customUserAgent', () {
    //       webView.customUserAgent = 'hello';
    //       verify(mockPlatformHostApi.setCustomUserAgent(
    //         webViewInstanceId,
    //         'hello',
    //       ));
    //     });
    //
    //     test('evaluateJavaScript', () {
    //       when(mockPlatformHostApi.evaluateJavaScript(
    //           webViewInstanceId, 'gogo'))
    //           .thenAnswer((_) => Future<String>.value('stopstop'));
    //       expect(webView.evaluateJavaScript('gogo'), completion('stopstop'));
    //     });
    //
    //     test('setNavigationDelegate', () {
    //       final NavigationDelegate mockNavigationDelegate =
    //       MockNavigationDelegate();
    //       final int mockNavigationDelegateInstanceId =
    //       instanceManager.tryAddInstance(mockNavigationDelegate)!;
    //
    //       webView.navigationDelegate = mockNavigationDelegate;
    //       verify(mockPlatformHostApi.setNavigationDelegate(
    //         webViewInstanceId,
    //         mockNavigationDelegateInstanceId,
    //       ));
    //     });
    //
    //     test('setIosDelegate', () {
    //       final IosDelegate mockIosDelegate = MockIosDelegate();
    //       final int mockIosDelegateInstanceId =
    //       instanceManager.tryAddInstance(mockIosDelegate)!;
    //
    //       webView.iosDelegate = mockIosDelegate;
    //       verify(mockPlatformHostApi.setIosDelegate(
    //         webViewInstanceId,
    //         mockIosDelegateInstanceId,
    //       ));
    //     });
    //   });
    // });
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
    // group('$IosView', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$IosViewHostApiImpl', () {
    //     late MockTestIosViewHostApi mockPlatformHostApi;
    //
    //     late IosView iosView;
    //     late int iosViewInstanceId;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestIosViewHostApi();
    //       TestIosViewHostApi.setup(mockPlatformHostApi);
    //       IosView.api = IosViewHostApiImpl(instanceManager: instanceManager);
    //
    //       iosView = IosView();
    //       iosViewInstanceId = instanceManager.tryAddInstance(iosView)!;
    //     });
    //
    //     test('backgroundColor', () {
    //       iosView.backgroundColor = material.Colors.red;
    //       verify(mockPlatformHostApi.setBackgroundColor(
    //         iosViewInstanceId,
    //         material.Colors.red.value,
    //       ));
    //     });
    //
    //     test('opaque', () {
    //       iosView.opaque = false;
    //       verify(mockPlatformHostApi.setOpaque(iosViewInstanceId, false));
    //     });
    //   });
    // });
    //
    // group('$IosDelegate', () {
    //   late InstanceManager instanceManager;
    //
    //   setUp(() {
    //     instanceManager = InstanceManager();
    //   });
    //
    //   group('$IosDelegateHostApiImpl', () {
    //     late MockTestIosDelegateHostApi mockPlatformHostApi;
    //
    //     setUp(() {
    //       mockPlatformHostApi = MockTestIosDelegateHostApi();
    //       TestIosDelegateHostApi.setup(mockPlatformHostApi);
    //     });
    //
    //     test('create', () async {
    //       final InstanceManager createInstanceManager = InstanceManager();
    //       IosDelegate.api = IosDelegateHostApiImpl(
    //         instanceManager: createInstanceManager,
    //       );
    //       final IosDelegate instance = MockIosDelegate();
    //       await IosDelegate.api.createFromInstance(instance);
    //       expect(createInstanceManager.getInstance(0), instance);
    //     });
    //   });
    //
    //   group('$IosDelegateFlutterApiImpl', () {
    //     late IosDelegateFlutterApiImpl flutterApi;
    //
    //     late MockIosDelegate mockIosDelegate;
    //     late int iosDelegateInstanceId;
    //
    //     setUp(() {
    //       flutterApi =
    //           IosDelegateFlutterApiImpl(instanceManager: instanceManager);
    //       mockIosDelegate = MockIosDelegate();
    //       instanceManager.tryAddInstance(mockIosDelegate);
    //       iosDelegateInstanceId =
    //       instanceManager.getInstanceId(mockIosDelegate)!;
    //     });
    //
    //     test('onCreateWebView', () {
    //       final WebViewConfiguration configuration = WebViewConfiguration();
    //       final int configurationInstanceId =
    //       instanceManager.tryAddInstance(configuration)!;
    //       final UrlRequestData urlRequest = UrlRequestData()..url = 'apple';
    //       final FrameInfoData targetFrame = FrameInfoData()
    //         ..isMainFrame = false;
    //       flutterApi.onCreateWebView(
    //         iosDelegateInstanceId,
    //         configurationInstanceId,
    //         NavigationActionData()
    //           ..request = urlRequest
    //           ..targetFrame = targetFrame,
    //       );
    //       verify(mockIosDelegate.onCreateWebView(
    //         configuration,
    //         argThat(isA<NavigationAction>()),
    //       ));
    //     });
    //   });
    // });
  });
}
