// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.pigeon.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';

import '../common/test_web_kit.pigeon.dart';
import 'web_kit_test.mocks.dart';

@GenerateMocks(<Type>[
  TestWKNavigationDelegateHostApi,
  TestWKPreferencesHostApi,
  TestWKScriptMessageHandlerHostApi,
  TestWKUIDelegateHostApi,
  TestWKUserContentControllerHostApi,
  TestWKWebViewConfigurationHostApi,
  TestWKWebViewHostApi,
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

      late WKWebViewConfiguration webViewConfiguration;

      setUp(() {
        mockPlatformHostApi = MockTestWKWebsiteDataStoreHostApi();
        TestWKWebsiteDataStoreHostApi.setup(mockPlatformHostApi);

        TestWKWebViewConfigurationHostApi.setup(
          MockTestWKWebViewConfigurationHostApi(),
        );
        webViewConfiguration = WKWebViewConfiguration(
          instanceManager: instanceManager,
        );

        websiteDataStore = WKWebsiteDataStore.fromWebViewConfiguration(
          webViewConfiguration,
          instanceManager: instanceManager,
        );
      });

      tearDown(() {
        TestWKWebsiteDataStoreHostApi.setup(null);
        TestWKWebViewConfigurationHostApi.setup(null);
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

    group('$WKScriptMessageHandler', () {
      late MockTestWKScriptMessageHandlerHostApi mockPlatformHostApi;

      late WKScriptMessageHandler scriptMessageHandler;

      setUp(() async {
        mockPlatformHostApi = MockTestWKScriptMessageHandlerHostApi();
        TestWKScriptMessageHandlerHostApi.setup(mockPlatformHostApi);

        scriptMessageHandler = WKScriptMessageHandler(
          instanceManager: instanceManager,
        );
      });

      tearDown(() {
        TestWKScriptMessageHandlerHostApi.setup(null);
      });

      test('create', () async {
        verify(mockPlatformHostApi.create(
          instanceManager.getInstanceId(scriptMessageHandler),
        ));
      });
    });

    group('$WKPreferences', () {
      late MockTestWKPreferencesHostApi mockPlatformHostApi;

      late WKPreferences preferences;

      late WKWebViewConfiguration webViewConfiguration;

      setUp(() {
        mockPlatformHostApi = MockTestWKPreferencesHostApi();
        TestWKPreferencesHostApi.setup(mockPlatformHostApi);

        TestWKWebViewConfigurationHostApi.setup(
          MockTestWKWebViewConfigurationHostApi(),
        );
        webViewConfiguration = WKWebViewConfiguration(
          instanceManager: instanceManager,
        );

        preferences = WKPreferences.fromWebViewConfiguration(
          webViewConfiguration,
          instanceManager: instanceManager,
        );
      });

      tearDown(() {
        TestWKPreferencesHostApi.setup(null);
        TestWKWebViewConfigurationHostApi.setup(null);
      });

      test('createFromWebViewConfiguration', () async {
        verify(mockPlatformHostApi.createFromWebViewConfiguration(
          instanceManager.getInstanceId(preferences),
          instanceManager.getInstanceId(webViewConfiguration),
        ));
      });

      test('setJavaScriptEnabled', () async {
        await preferences.setJavaScriptEnabled(true);
        verify(mockPlatformHostApi.setJavaScriptEnabled(
          instanceManager.getInstanceId(preferences),
          true,
        ));
      });
    });

    group('$WKUserContentController', () {
      late MockTestWKUserContentControllerHostApi mockPlatformHostApi;

      late WKUserContentController userContentController;

      late WKWebViewConfiguration webViewConfiguration;

      setUp(() {
        mockPlatformHostApi = MockTestWKUserContentControllerHostApi();
        TestWKUserContentControllerHostApi.setup(mockPlatformHostApi);

        TestWKWebViewConfigurationHostApi.setup(
          MockTestWKWebViewConfigurationHostApi(),
        );
        webViewConfiguration = WKWebViewConfiguration(
          instanceManager: instanceManager,
        );

        userContentController =
            WKUserContentController.fromWebViewConfiguration(
          webViewConfiguration,
          instanceManager: instanceManager,
        );
      });

      tearDown(() {
        TestWKUserContentControllerHostApi.setup(null);
        TestWKWebViewConfigurationHostApi.setup(null);
      });

      test('createFromWebViewConfiguration', () async {
        verify(mockPlatformHostApi.createFromWebViewConfiguration(
          instanceManager.getInstanceId(userContentController),
          instanceManager.getInstanceId(webViewConfiguration),
        ));
      });

      test('addScriptMessageHandler', () async {
        TestWKScriptMessageHandlerHostApi.setup(
          MockTestWKScriptMessageHandlerHostApi(),
        );
        final WKScriptMessageHandler handler = WKScriptMessageHandler(
          instanceManager: instanceManager,
        );

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
          instanceManager: instanceManager,
        );
      });

      tearDown(() {
        TestWKWebViewConfigurationHostApi.setup(null);
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
          instanceManager: instanceManager,
        );

        final WKWebViewConfiguration configurationFromWebView =
            WKWebViewConfiguration.fromWebView(
          webView,
          instanceManager: instanceManager,
        );
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
          instanceManager: instanceManager,
        );
      });

      tearDown(() {
        TestWKNavigationDelegateHostApi.setup(null);
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

        TestWKWebViewConfigurationHostApi.setup(
            MockTestWKWebViewConfigurationHostApi());
        webViewConfiguration = WKWebViewConfiguration(
          instanceManager: instanceManager,
        );

        webView = WKWebView(
          webViewConfiguration,
          instanceManager: instanceManager,
        );
        webViewInstanceId = instanceManager.getInstanceId(webView)!;
      });

      tearDown(() {
        TestWKWebViewHostApi.setup(null);
        TestWKWebViewConfigurationHostApi.setup(null);
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
        TestWKUIDelegateHostApi.setup(MockTestWKUIDelegateHostApi());
        final WKUIDelegate uiDelegate = WKUIDelegate(
          instanceManager: instanceManager,
        );

        await webView.setUIDelegate(uiDelegate);
        verify(mockPlatformHostApi.setUIDelegate(
          webViewInstanceId,
          instanceManager.getInstanceId(uiDelegate),
        ));

        TestWKUIDelegateHostApi.setup(null);
      });

      test('setNavigationDelegate', () async {
        TestWKNavigationDelegateHostApi.setup(
          MockTestWKNavigationDelegateHostApi(),
        );
        final WKNavigationDelegate navigationDelegate = WKNavigationDelegate(
          instanceManager: instanceManager,
        );

        await webView.setNavigationDelegate(navigationDelegate);
        verify(mockPlatformHostApi.setNavigationDelegate(
          webViewInstanceId,
          instanceManager.getInstanceId(navigationDelegate),
        ));

        TestWKNavigationDelegateHostApi.setup(null);
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

    group('$WKUIDelegate', () {
      late MockTestWKUIDelegateHostApi mockPlatformHostApi;

      late WKUIDelegate uiDelegate;

      setUp(() async {
        mockPlatformHostApi = MockTestWKUIDelegateHostApi();
        TestWKUIDelegateHostApi.setup(mockPlatformHostApi);

        uiDelegate = WKUIDelegate(instanceManager: instanceManager);
      });

      tearDown(() {
        TestWKUIDelegateHostApi.setup(null);
      });

      test('create', () async {
        verify(mockPlatformHostApi.create(
          instanceManager.getInstanceId(uiDelegate),
        ));
      });
    });
  });
}
