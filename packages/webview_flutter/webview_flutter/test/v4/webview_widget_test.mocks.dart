// Mocks generated by Mockito 5.3.0 from annotations
// in webview_flutter/test/v4/webview_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/widgets.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/v4/src/platform_webview_widget.dart'
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

class _FakePlatformWebViewWidgetCreationParams_0 extends _i1.SmartFake
    implements _i2.PlatformWebViewWidgetCreationParams {
  _FakePlatformWebViewWidgetCreationParams_0(
      Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeWidget_1 extends _i1.SmartFake implements _i3.Widget {
  _FakeWidget_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [PlatformWebViewWidget].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlatformWebViewWidget extends _i1.Mock
    implements _i4.PlatformWebViewWidget {
  MockPlatformWebViewWidget() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PlatformWebViewWidgetCreationParams get params =>
      (super.noSuchMethod(Invocation.getter(#params),
              returnValue: _FakePlatformWebViewWidgetCreationParams_0(
                  this, Invocation.getter(#params)))
          as _i2.PlatformWebViewWidgetCreationParams);
  @override
  _i3.Widget build(_i3.BuildContext? context) =>
      (super.noSuchMethod(Invocation.method(#build, [context]),
              returnValue:
                  _FakeWidget_1(this, Invocation.method(#build, [context])))
          as _i3.Widget);
}
