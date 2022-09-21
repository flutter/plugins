// Mocks generated by Mockito 5.3.1 from annotations
// in webview_flutter/test/v4/webview_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:math' as _i3;
import 'dart:ui' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/v4/src/platform_navigation_delegate.dart'
    as _i6;
import 'package:webview_flutter_platform_interface/v4/src/platform_webview_controller.dart'
    as _i4;
import 'package:webview_flutter_platform_interface/v4/src/webview_platform.dart'
    as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakePlatformWebViewControllerCreationParams_0 extends _i1.SmartFake
    implements _i2.PlatformWebViewControllerCreationParams {
  _FakePlatformWebViewControllerCreationParams_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePoint_1<T extends num> extends _i1.SmartFake
    implements _i3.Point<T> {
  _FakePoint_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformNavigationDelegateCreationParams_2 extends _i1.SmartFake
    implements _i2.PlatformNavigationDelegateCreationParams {
  _FakePlatformNavigationDelegateCreationParams_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [PlatformWebViewController].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlatformWebViewController extends _i1.Mock
    implements _i4.PlatformWebViewController {
  MockPlatformWebViewController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PlatformWebViewControllerCreationParams get params => (super.noSuchMethod(
        Invocation.getter(#params),
        returnValue: _FakePlatformWebViewControllerCreationParams_0(
          this,
          Invocation.getter(#params),
        ),
      ) as _i2.PlatformWebViewControllerCreationParams);
  @override
  _i5.Future<void> loadFile(String? absoluteFilePath) => (super.noSuchMethod(
        Invocation.method(
          #loadFile,
          [absoluteFilePath],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> loadFlutterAsset(String? key) => (super.noSuchMethod(
        Invocation.method(
          #loadFlutterAsset,
          [key],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> loadHtmlString(
    String? html, {
    String? baseUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadHtmlString,
          [html],
          {#baseUrl: baseUrl},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> loadRequest(_i2.LoadRequestParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadRequest,
          [params],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<String?> currentUrl() => (super.noSuchMethod(
        Invocation.method(
          #currentUrl,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);
  @override
  _i5.Future<bool> canGoBack() => (super.noSuchMethod(
        Invocation.method(
          #canGoBack,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
  @override
  _i5.Future<bool> canGoForward() => (super.noSuchMethod(
        Invocation.method(
          #canGoForward,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
  @override
  _i5.Future<void> goBack() => (super.noSuchMethod(
        Invocation.method(
          #goBack,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> goForward() => (super.noSuchMethod(
        Invocation.method(
          #goForward,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> clearCache() => (super.noSuchMethod(
        Invocation.method(
          #clearCache,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> clearLocalStorage() => (super.noSuchMethod(
        Invocation.method(
          #clearLocalStorage,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setPlatformNavigationDelegate(
          _i6.PlatformNavigationDelegate? handler) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPlatformNavigationDelegate,
          [handler],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> runJavaScript(String? javaScript) => (super.noSuchMethod(
        Invocation.method(
          #runJavaScript,
          [javaScript],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<String> runJavaScriptReturningResult(String? javaScript) =>
      (super.noSuchMethod(
        Invocation.method(
          #runJavaScriptReturningResult,
          [javaScript],
        ),
        returnValue: _i5.Future<String>.value(''),
      ) as _i5.Future<String>);
  @override
  _i5.Future<void> addJavaScriptChannel(
          _i4.JavaScriptChannelParams? javaScriptChannelParams) =>
      (super.noSuchMethod(
        Invocation.method(
          #addJavaScriptChannel,
          [javaScriptChannelParams],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> removeJavaScriptChannel(String? javaScriptChannelName) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeJavaScriptChannel,
          [javaScriptChannelName],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<String?> getTitle() => (super.noSuchMethod(
        Invocation.method(
          #getTitle,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);
  @override
  _i5.Future<void> scrollTo(
    int? x,
    int? y,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #scrollTo,
          [
            x,
            y,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> scrollBy(
    int? x,
    int? y,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #scrollBy,
          [
            x,
            y,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<_i3.Point<int>> getScrollPosition() => (super.noSuchMethod(
        Invocation.method(
          #getScrollPosition,
          [],
        ),
        returnValue: _i5.Future<_i3.Point<int>>.value(_FakePoint_1<int>(
          this,
          Invocation.method(
            #getScrollPosition,
            [],
          ),
        )),
      ) as _i5.Future<_i3.Point<int>>);
  @override
  _i5.Future<void> enableDebugging(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #enableDebugging,
          [enabled],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> enableGestureNavigation(bool? enabled) =>
      (super.noSuchMethod(
        Invocation.method(
          #enableGestureNavigation,
          [enabled],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> enableZoom(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #enableZoom,
          [enabled],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setBackgroundColor(_i7.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setJavaScriptMode(_i2.JavaScriptMode? javaScriptMode) =>
      (super.noSuchMethod(
        Invocation.method(
          #setJavaScriptMode,
          [javaScriptMode],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setUserAgent(String? userAgent) => (super.noSuchMethod(
        Invocation.method(
          #setUserAgent,
          [userAgent],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [PlatformNavigationDelegate].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlatformNavigationDelegate extends _i1.Mock
    implements _i6.PlatformNavigationDelegate {
  MockPlatformNavigationDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PlatformNavigationDelegateCreationParams get params =>
      (super.noSuchMethod(
        Invocation.getter(#params),
        returnValue: _FakePlatformNavigationDelegateCreationParams_2(
          this,
          Invocation.getter(#params),
        ),
      ) as _i2.PlatformNavigationDelegateCreationParams);
  @override
  _i5.Future<void> setOnNavigationRequest(
          _i6.NavigationRequestCallback? onNavigationRequest) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnNavigationRequest,
          [onNavigationRequest],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnPageStarted(_i6.PageEventCallback? onPageStarted) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnPageStarted,
          [onPageStarted],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnPageFinished(_i6.PageEventCallback? onPageFinished) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnPageFinished,
          [onPageFinished],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnProgress(_i6.ProgressCallback? onProgress) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnProgress,
          [onProgress],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnWebResourceError(
          _i6.WebResourceErrorCallback? onWebResourceError) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnWebResourceError,
          [onWebResourceError],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}
