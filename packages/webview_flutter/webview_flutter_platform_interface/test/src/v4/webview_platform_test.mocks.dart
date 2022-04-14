// Mocks generated by Mockito 5.0.16 from annotations
// in webview_flutter_platform_interface/test/src/v4/webview_platform_test.dart.
// Do not manually edit this file.

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/src/v4/navigation_callback_delegate.dart'
    as _i3;
import 'package:webview_flutter_platform_interface/src/v4/types/types.dart'
    as _i7;
import 'package:webview_flutter_platform_interface/src/v4/types/webview_widget_creation_params.dart'
    as _i8;
import 'package:webview_flutter_platform_interface/src/v4/webview_controller_delegate.dart'
    as _i4;
import 'package:webview_flutter_platform_interface/src/v4/webview_cookie_manager_delegate.dart'
    as _i2;
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart'
    as _i6;
import 'package:webview_flutter_platform_interface/src/v4/webview_widget_delegate.dart'
    as _i5;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeWebViewCookieManagerDelegate_0 extends _i1.Fake
    implements _i2.WebViewCookieManagerDelegate {}

class _FakeNavigationCallbackDelegate_1 extends _i1.Fake
    implements _i3.NavigationCallbackDelegate {}

class _FakeWebViewControllerDelegate_2 extends _i1.Fake
    implements _i4.WebViewControllerDelegate {}

class _FakeWebViewWidgetDelegate_3 extends _i1.Fake
    implements _i5.WebViewWidgetDelegate {}

/// A class which mocks [WebViewPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewPlatform extends _i1.Mock implements _i6.WebViewPlatform {
  MockWebViewPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WebViewCookieManagerDelegate createCookieManagerDelegate(
          _i7.WebViewCookieManagerCreationParams? params) =>
      (super.noSuchMethod(
              Invocation.method(#createCookieManagerDelegate, [params]),
              returnValue: _FakeWebViewCookieManagerDelegate_0())
          as _i2.WebViewCookieManagerDelegate);
  @override
  _i3.NavigationCallbackDelegate createNavigationCallbackDelegate(
          _i7.NavigationCallbackCreationParams? params) =>
      (super.noSuchMethod(
              Invocation.method(#createNavigationCallbackDelegate, [params]),
              returnValue: _FakeNavigationCallbackDelegate_1())
          as _i3.NavigationCallbackDelegate);
  @override
  _i4.WebViewControllerDelegate createWebViewControllerDelegate(
          _i7.WebViewControllerCreationParams? params) =>
      (super.noSuchMethod(
              Invocation.method(#createWebViewControllerDelegate, [params]),
              returnValue: _FakeWebViewControllerDelegate_2())
          as _i4.WebViewControllerDelegate);
  @override
  _i5.WebViewWidgetDelegate createWebViewWidgetDelegate(
          _i8.WebViewWidgetCreationParams? params) =>
      (super.noSuchMethod(
              Invocation.method(#createWebViewWidgetDelegate, [params]),
              returnValue: _FakeWebViewWidgetDelegate_3())
          as _i5.WebViewWidgetDelegate);
  @override
  String toString() => super.toString();
}
