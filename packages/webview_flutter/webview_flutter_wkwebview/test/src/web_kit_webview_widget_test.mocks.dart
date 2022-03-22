// Mocks generated by Mockito 5.1.0 from annotations
// in webview_flutter_wkwebview/example/ios/.symlinks/plugins/webview_flutter_wkwebview/test/src/web_kit_webview_widget_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;
import 'dart:math' as _i2;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/src/types/javascript_channel.dart'
    as _i8;
import 'package:webview_flutter_platform_interface/src/types/types.dart' as _i9;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as _i7;
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart'
    as _i6;
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart' as _i4;
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart' as _i3;
import 'package:webview_flutter_wkwebview/src/web_kit_webview_widget.dart'
    as _i10;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakePoint_0<T extends num> extends _i1.Fake implements _i2.Point<T> {}

class _FakeWKWebViewConfiguration_1 extends _i1.Fake
    implements _i3.WKWebViewConfiguration {}

class _FakeUIScrollView_2 extends _i1.Fake implements _i4.UIScrollView {}

class _FakeWKUserContentController_3 extends _i1.Fake
    implements _i3.WKUserContentController {}

class _FakeWKWebsiteDataStore_4 extends _i1.Fake
    implements _i3.WKWebsiteDataStore {}

class _FakeWKWebView_5 extends _i1.Fake implements _i3.WKWebView {}

class _FakeWKScriptMessageHandler_6 extends _i1.Fake
    implements _i3.WKScriptMessageHandler {}

class _FakeWKUIDelegate_7 extends _i1.Fake implements _i3.WKUIDelegate {}

class _FakeWKNavigationDelegate_8 extends _i1.Fake
    implements _i3.WKNavigationDelegate {}

/// A class which mocks [UIScrollView].
///
/// See the documentation for Mockito's code generation for more information.
class MockUIScrollView extends _i1.Mock implements _i4.UIScrollView {
  MockUIScrollView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Point<double>> get contentOffset => (super.noSuchMethod(
          Invocation.getter(#contentOffset),
          returnValue: Future<_i2.Point<double>>.value(_FakePoint_0<double>()))
      as _i5.Future<_i2.Point<double>>);
  @override
  set contentOffset(_i5.FutureOr<_i2.Point<double>>? offset) =>
      super.noSuchMethod(Invocation.setter(#contentOffset, offset),
          returnValueForMissingStub: null);
  @override
  _i5.Future<void> scrollBy(_i2.Point<double>? offset) =>
      (super.noSuchMethod(Invocation.method(#scrollBy, [offset]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
}

/// A class which mocks [WKNavigationDelegate].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKNavigationDelegate extends _i1.Mock
    implements _i3.WKNavigationDelegate {
  MockWKNavigationDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set didStartProvisionalNavigation(
          void Function(_i3.WKWebView, String?)?
              didStartProvisionalNavigation) =>
      super.noSuchMethod(
          Invocation.setter(
              #didStartProvisionalNavigation, didStartProvisionalNavigation),
          returnValueForMissingStub: null);
  @override
  set didFinishNavigation(
          void Function(_i3.WKWebView, String?)? didFinishNavigation) =>
      super.noSuchMethod(
          Invocation.setter(#didFinishNavigation, didFinishNavigation),
          returnValueForMissingStub: null);
  @override
  set decidePolicyForNavigationAction(
          _i5.Future<_i3.WKNavigationActionPolicy> Function(
                  _i3.WKWebView, _i3.WKNavigationAction)?
              decidePolicyForNavigationAction) =>
      super.noSuchMethod(
          Invocation.setter(#decidePolicyForNavigationAction,
              decidePolicyForNavigationAction),
          returnValueForMissingStub: null);
  @override
  set didFailNavigation(
          void Function(_i3.WKWebView, _i6.NSError)? didFailNavigation) =>
      super.noSuchMethod(
          Invocation.setter(#didFailNavigation, didFailNavigation),
          returnValueForMissingStub: null);
  @override
  set didFailProvisionalNavigation(
          void Function(_i3.WKWebView, _i6.NSError)?
              didFailProvisionalNavigation) =>
      super.noSuchMethod(
          Invocation.setter(
              #didFailProvisionalNavigation, didFailProvisionalNavigation),
          returnValueForMissingStub: null);
  @override
  set webViewWebContentProcessDidTerminate(
          void Function(_i3.WKWebView)? webViewWebContentProcessDidTerminate) =>
      super.noSuchMethod(
          Invocation.setter(#webViewWebContentProcessDidTerminate,
              webViewWebContentProcessDidTerminate),
          returnValueForMissingStub: null);
}

/// A class which mocks [WKScriptMessageHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKScriptMessageHandler extends _i1.Mock
    implements _i3.WKScriptMessageHandler {
  MockWKScriptMessageHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set didReceiveScriptMessage(
          void Function(_i3.WKUserContentController, _i3.WKScriptMessage)?
              didReceiveScriptMessage) =>
      super.noSuchMethod(
          Invocation.setter(#didReceiveScriptMessage, didReceiveScriptMessage),
          returnValueForMissingStub: null);
}

/// A class which mocks [WKWebView].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKWebView extends _i1.Mock implements _i3.WKWebView {
  MockWKWebView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.WKWebViewConfiguration get configuration =>
      (super.noSuchMethod(Invocation.getter(#configuration),
              returnValue: _FakeWKWebViewConfiguration_1())
          as _i3.WKWebViewConfiguration);
  @override
  _i4.UIScrollView get scrollView =>
      (super.noSuchMethod(Invocation.getter(#scrollView),
          returnValue: _FakeUIScrollView_2()) as _i4.UIScrollView);
  @override
  set uiDelegate(_i3.WKUIDelegate? delegate) =>
      super.noSuchMethod(Invocation.setter(#uiDelegate, delegate),
          returnValueForMissingStub: null);
  @override
  set navigationDelegate(_i3.WKNavigationDelegate? delegate) =>
      super.noSuchMethod(Invocation.setter(#navigationDelegate, delegate),
          returnValueForMissingStub: null);
  @override
  _i5.Future<String?> get url => (super.noSuchMethod(Invocation.getter(#url),
      returnValue: Future<String?>.value()) as _i5.Future<String?>);
  @override
  _i5.Future<bool> get canGoBack =>
      (super.noSuchMethod(Invocation.getter(#canGoBack),
          returnValue: Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<bool> get canGoForward =>
      (super.noSuchMethod(Invocation.getter(#canGoForward),
          returnValue: Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<String?> get title =>
      (super.noSuchMethod(Invocation.getter(#title),
          returnValue: Future<String?>.value()) as _i5.Future<String?>);
  @override
  _i5.Future<double> get estimatedProgress =>
      (super.noSuchMethod(Invocation.getter(#estimatedProgress),
          returnValue: Future<double>.value(0.0)) as _i5.Future<double>);
  @override
  set allowsBackForwardNavigationGestures(bool? allow) => super.noSuchMethod(
      Invocation.setter(#allowsBackForwardNavigationGestures, allow),
      returnValueForMissingStub: null);
  @override
  set customUserAgent(String? userAgent) =>
      super.noSuchMethod(Invocation.setter(#customUserAgent, userAgent),
          returnValueForMissingStub: null);
  @override
  _i5.Future<void> loadRequest(_i6.NSUrlRequest? request) =>
      (super.noSuchMethod(Invocation.method(#loadRequest, [request]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> loadHtmlString(String? string, {String? baseUrl}) =>
      (super.noSuchMethod(
          Invocation.method(#loadHtmlString, [string], {#baseUrl: baseUrl}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> loadFileUrl(String? url, {String? readAccessUrl}) =>
      (super.noSuchMethod(
          Invocation.method(
              #loadFileUrl, [url], {#readAccessUrl: readAccessUrl}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> loadFlutterAsset(String? key) =>
      (super.noSuchMethod(Invocation.method(#loadFlutterAsset, [key]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> goBack() =>
      (super.noSuchMethod(Invocation.method(#goBack, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> goForward() =>
      (super.noSuchMethod(Invocation.method(#goForward, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> reload() =>
      (super.noSuchMethod(Invocation.method(#reload, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<Object?> evaluateJavaScript(String? javaScriptString) => (super
      .noSuchMethod(Invocation.method(#evaluateJavaScript, [javaScriptString]),
          returnValue: Future<Object?>.value()) as _i5.Future<Object?>);
}

/// A class which mocks [WKWebViewConfiguration].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKWebViewConfiguration extends _i1.Mock
    implements _i3.WKWebViewConfiguration {
  MockWKWebViewConfiguration() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.WKUserContentController get userContentController =>
      (super.noSuchMethod(Invocation.getter(#userContentController),
              returnValue: _FakeWKUserContentController_3())
          as _i3.WKUserContentController);
  @override
  set userContentController(
          _i3.WKUserContentController? _userContentController) =>
      super.noSuchMethod(
          Invocation.setter(#userContentController, _userContentController),
          returnValueForMissingStub: null);
  @override
  _i3.WKWebsiteDataStore get webSiteDataStore =>
      (super.noSuchMethod(Invocation.getter(#webSiteDataStore),
          returnValue: _FakeWKWebsiteDataStore_4()) as _i3.WKWebsiteDataStore);
  @override
  set webSiteDataStore(_i3.WKWebsiteDataStore? websiteDataStore) =>
      super.noSuchMethod(Invocation.setter(#webSiteDataStore, websiteDataStore),
          returnValueForMissingStub: null);
  @override
  set allowsInlineMediaPlayback(bool? allow) =>
      super.noSuchMethod(Invocation.setter(#allowsInlineMediaPlayback, allow),
          returnValueForMissingStub: null);
  @override
  set mediaTypesRequiringUserActionForPlayback(
          Set<_i3.WKAudiovisualMediaType>? types) =>
      super.noSuchMethod(
          Invocation.setter(#mediaTypesRequiringUserActionForPlayback, types),
          returnValueForMissingStub: null);
}

/// A class which mocks [WKWebsiteDataStore].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKWebsiteDataStore extends _i1.Mock
    implements _i3.WKWebsiteDataStore {
  MockWKWebsiteDataStore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> removeDataOfTypes(
          Set<_i3.WKWebsiteDataTypes>? dataTypes, DateTime? since) =>
      (super.noSuchMethod(
          Invocation.method(#removeDataOfTypes, [dataTypes, since]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
}

/// A class which mocks [WKUIDelegate].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKUIDelegate extends _i1.Mock implements _i3.WKUIDelegate {
  MockWKUIDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set onCreateWebView(
          void Function(_i3.WKWebViewConfiguration, _i3.WKNavigationAction)?
              onCreateeWebView) =>
      super.noSuchMethod(Invocation.setter(#onCreateWebView, onCreateeWebView),
          returnValueForMissingStub: null);
}

/// A class which mocks [WKUserContentController].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKUserContentController extends _i1.Mock
    implements _i3.WKUserContentController {
  MockWKUserContentController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> addScriptMessageHandler(
          _i3.WKScriptMessageHandler? handler, String? name) =>
      (super.noSuchMethod(
          Invocation.method(#addScriptMessageHandler, [handler, name]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> removeScriptMessageHandler(String? name) => (super
      .noSuchMethod(Invocation.method(#removeScriptMessageHandler, [name]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> removeAllScriptMessageHandlers() => (super.noSuchMethod(
      Invocation.method(#removeAllScriptMessageHandlers, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> addUserScript(_i3.WKUserScript? userScript) =>
      (super.noSuchMethod(Invocation.method(#addUserScript, [userScript]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> removeAllUserScripts() =>
      (super.noSuchMethod(Invocation.method(#removeAllUserScripts, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
}

/// A class which mocks [JavascriptChannelRegistry].
///
/// See the documentation for Mockito's code generation for more information.
class MockJavascriptChannelRegistry extends _i1.Mock
    implements _i7.JavascriptChannelRegistry {
  MockJavascriptChannelRegistry() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<String, _i8.JavascriptChannel> get channels =>
      (super.noSuchMethod(Invocation.getter(#channels),
              returnValue: <String, _i8.JavascriptChannel>{})
          as Map<String, _i8.JavascriptChannel>);
  @override
  void onJavascriptChannelMessage(String? channel, String? message) =>
      super.noSuchMethod(
          Invocation.method(#onJavascriptChannelMessage, [channel, message]),
          returnValueForMissingStub: null);
  @override
  void updateJavascriptChannelsFromSet(Set<_i8.JavascriptChannel>? channels) =>
      super.noSuchMethod(
          Invocation.method(#updateJavascriptChannelsFromSet, [channels]),
          returnValueForMissingStub: null);
}

/// A class which mocks [WebViewPlatformCallbacksHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewPlatformCallbacksHandler extends _i1.Mock
    implements _i7.WebViewPlatformCallbacksHandler {
  MockWebViewPlatformCallbacksHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.FutureOr<bool> onNavigationRequest({String? url, bool? isForMainFrame}) =>
      (super.noSuchMethod(
          Invocation.method(#onNavigationRequest, [],
              {#url: url, #isForMainFrame: isForMainFrame}),
          returnValue: Future<bool>.value(false)) as _i5.FutureOr<bool>);
  @override
  void onPageStarted(String? url) =>
      super.noSuchMethod(Invocation.method(#onPageStarted, [url]),
          returnValueForMissingStub: null);
  @override
  void onPageFinished(String? url) =>
      super.noSuchMethod(Invocation.method(#onPageFinished, [url]),
          returnValueForMissingStub: null);
  @override
  void onProgress(int? progress) =>
      super.noSuchMethod(Invocation.method(#onProgress, [progress]),
          returnValueForMissingStub: null);
  @override
  void onWebResourceError(_i9.WebResourceError? error) =>
      super.noSuchMethod(Invocation.method(#onWebResourceError, [error]),
          returnValueForMissingStub: null);
}

/// A class which mocks [WebViewWidgetProxy].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewWidgetProxy extends _i1.Mock
    implements _i10.WebViewWidgetProxy {
  MockWebViewWidgetProxy() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.WKWebView createWebView(_i3.WKWebViewConfiguration? configuration) =>
      (super.noSuchMethod(Invocation.method(#createWebView, [configuration]),
          returnValue: _FakeWKWebView_5()) as _i3.WKWebView);
  @override
  _i3.WKScriptMessageHandler createScriptMessageHandler() =>
      (super.noSuchMethod(Invocation.method(#createScriptMessageHandler, []),
              returnValue: _FakeWKScriptMessageHandler_6())
          as _i3.WKScriptMessageHandler);
  @override
  _i3.WKUIDelegate createUIDelgate() =>
      (super.noSuchMethod(Invocation.method(#createUIDelgate, []),
          returnValue: _FakeWKUIDelegate_7()) as _i3.WKUIDelegate);
  @override
  _i3.WKNavigationDelegate createNavigationDelegate() => (super.noSuchMethod(
      Invocation.method(#createNavigationDelegate, []),
      returnValue: _FakeWKNavigationDelegate_8()) as _i3.WKNavigationDelegate);
}
