// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Mocks generated by Mockito 5.0.16 from annotations
// in webview_flutter/test/webview_flutter_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i9;

import 'package:flutter/foundation.dart' as _i3;
import 'package:flutter/gestures.dart' as _i8;
import 'package:flutter/widgets.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/src/platform_interface/javascript_channel_registry.dart'
    as _i7;
import 'package:webview_flutter_platform_interface/src/platform_interface/webview_platform.dart'
    as _i4;
import 'package:webview_flutter_platform_interface/src/platform_interface/webview_platform_callbacks_handler.dart'
    as _i6;
import 'package:webview_flutter_platform_interface/src/platform_interface/webview_platform_controller.dart'
    as _i10;
import 'package:webview_flutter_platform_interface/src/types/types.dart' as _i5;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeWidget_0 extends _i1.Fake implements _i2.Widget {
  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [WebViewPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewPlatform extends _i1.Mock implements _i4.WebViewPlatform {
  MockWebViewPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Widget build(
          {_i2.BuildContext? context,
          _i5.CreationParams? creationParams,
          _i6.WebViewPlatformCallbacksHandler? webViewPlatformCallbacksHandler,
          _i7.JavascriptChannelRegistry? javascriptChannelRegistry,
          _i4.WebViewPlatformCreatedCallback? onWebViewPlatformCreated,
          Set<_i3.Factory<_i8.OneSequenceGestureRecognizer>>?
              gestureRecognizers}) =>
      (super.noSuchMethod(
          Invocation.method(#build, [], {
            #context: context,
            #creationParams: creationParams,
            #webViewPlatformCallbacksHandler: webViewPlatformCallbacksHandler,
            #javascriptChannelRegistry: javascriptChannelRegistry,
            #onWebViewPlatformCreated: onWebViewPlatformCreated,
            #gestureRecognizers: gestureRecognizers
          }),
          returnValue: _FakeWidget_0()) as _i2.Widget);
  @override
  _i9.Future<bool> clearCookies() =>
      (super.noSuchMethod(Invocation.method(#clearCookies, []),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [WebViewPlatformController].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewPlatformController extends _i1.Mock
    implements _i10.WebViewPlatformController {
  MockWebViewPlatformController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Future<void> loadFile(String? absoluteFilePath) =>
      (super.noSuchMethod(Invocation.method(#loadFile, [absoluteFilePath]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> loadHtmlString(String? html, {String? baseUrl}) =>
      (super.noSuchMethod(
          Invocation.method(#loadHtmlString, [html], {#baseUrl: baseUrl}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> loadUrl(String? url, Map<String, String>? headers) =>
      (super.noSuchMethod(Invocation.method(#loadUrl, [url, headers]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> loadRequest(_i5.WebViewRequest? request) =>
      (super.noSuchMethod(Invocation.method(#loadRequest, [request]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> updateSettings(_i5.WebSettings? setting) =>
      (super.noSuchMethod(Invocation.method(#updateSettings, [setting]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<String?> currentUrl() =>
      (super.noSuchMethod(Invocation.method(#currentUrl, []),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<bool> canGoBack() =>
      (super.noSuchMethod(Invocation.method(#canGoBack, []),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> canGoForward() =>
      (super.noSuchMethod(Invocation.method(#canGoForward, []),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<void> goBack() =>
      (super.noSuchMethod(Invocation.method(#goBack, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> goForward() =>
      (super.noSuchMethod(Invocation.method(#goForward, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> reload() =>
      (super.noSuchMethod(Invocation.method(#reload, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> clearCache() =>
      (super.noSuchMethod(Invocation.method(#clearCache, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<String> evaluateJavascript(String? javascript) =>
      (super.noSuchMethod(Invocation.method(#evaluateJavascript, [javascript]),
          returnValue: Future<String>.value('')) as _i9.Future<String>);
  @override
  _i9.Future<void> runJavascript(String? javascript) =>
      (super.noSuchMethod(Invocation.method(#runJavascript, [javascript]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<String> runJavascriptReturningResult(String? javascript) =>
      (super.noSuchMethod(
          Invocation.method(#runJavascriptReturningResult, [javascript]),
          returnValue: Future<String>.value('')) as _i9.Future<String>);
  @override
  _i9.Future<void> addJavascriptChannels(Set<String>? javascriptChannelNames) =>
      (super.noSuchMethod(
          Invocation.method(#addJavascriptChannels, [javascriptChannelNames]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> removeJavascriptChannels(
          Set<String>? javascriptChannelNames) =>
      (super.noSuchMethod(
          Invocation.method(
              #removeJavascriptChannels, [javascriptChannelNames]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<String?> getTitle() =>
      (super.noSuchMethod(Invocation.method(#getTitle, []),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<void> scrollTo(int? x, int? y) =>
      (super.noSuchMethod(Invocation.method(#scrollTo, [x, y]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> scrollBy(int? x, int? y) =>
      (super.noSuchMethod(Invocation.method(#scrollBy, [x, y]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<int> getScrollX() =>
      (super.noSuchMethod(Invocation.method(#getScrollX, []),
          returnValue: Future<int>.value(0)) as _i9.Future<int>);
  @override
  _i9.Future<int> getScrollY() =>
      (super.noSuchMethod(Invocation.method(#getScrollY, []),
          returnValue: Future<int>.value(0)) as _i9.Future<int>);
  @override
  String toString() => super.toString();
}
