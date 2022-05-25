// Mocks generated by Mockito 5.1.0 from annotations
// in webview_flutter_android/test/v4/android_webview_cookie_manager_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_android/src/android_webview.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [CookieManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockCookieManager extends _i1.Mock implements _i2.CookieManager {
  MockCookieManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> setCookie(String? url, String? value) =>
      (super.noSuchMethod(Invocation.method(#setCookie, [url, value]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<bool> clearCookies() =>
      (super.noSuchMethod(Invocation.method(#clearCookies, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
}
