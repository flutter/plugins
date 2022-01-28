// Mocks generated by Mockito 5.0.16 from annotations
// in regular_integration_tests/integration_test/url_launcher_web_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;
import 'dart:html' as _i2;
import 'dart:math' as _i4;

import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types


class _FakeDocument_0 extends _i1.Fake implements _i2.Document {}

class _FakeLocation_1 extends _i1.Fake implements _i2.Location {}

class _FakeConsole_2 extends _i1.Fake implements _i2.Console {}

class _FakeHistory_3 extends _i1.Fake implements _i2.History {}

class _FakeStorage_4 extends _i1.Fake implements _i2.Storage {}

class _FakeNavigator_5 extends _i1.Fake implements _i2.Navigator {}

class _FakePerformance_6 extends _i1.Fake implements _i2.Performance {}

class _FakeEvents_7 extends _i1.Fake implements _i2.Events {}

class _FakeWindowBase_8 extends _i1.Fake implements _i2.WindowBase {}

class _FakeFileSystem_9 extends _i1.Fake implements _i2.FileSystem {}

class _FakeStylePropertyMapReadonly_10 extends _i1.Fake
    implements _i2.StylePropertyMapReadonly {}

class _FakeMediaQueryList_11 extends _i1.Fake implements _i2.MediaQueryList {}

class _FakeEntry_12 extends _i1.Fake implements _i2.Entry {}

class _FakeGeolocation_13 extends _i1.Fake implements _i2.Geolocation {}

class _FakeMediaStream_14 extends _i1.Fake implements _i2.MediaStream {}

class _FakeRelatedApplication_15 extends _i1.Fake
    implements _i2.RelatedApplication {}

/// A class which mocks [Window].
///
/// See the documentation for Mockito's code generation for more information.
class MockWindow extends _i1.Mock implements _i2.Window {
  MockWindow() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<num> get animationFrame =>
      (super.noSuchMethod(Invocation.getter(#animationFrame),
          returnValue: Future<num>.value(0)) as _i3.Future<num>);
  @override
  _i2.Document get document => (super.noSuchMethod(Invocation.getter(#document),
      returnValue: _FakeDocument_0()) as _i2.Document);
  @override
  _i2.Location get location => (super.noSuchMethod(Invocation.getter(#location),
      returnValue: _FakeLocation_1()) as _i2.Location);
  @override
  set location(_i2.LocationBase? value) =>
      super.noSuchMethod(Invocation.setter(#location, value),
          returnValueForMissingStub: null);
  @override
  _i2.Console get console => (super.noSuchMethod(Invocation.getter(#console),
      returnValue: _FakeConsole_2()) as _i2.Console);
  @override
  set defaultStatus(String? value) =>
      super.noSuchMethod(Invocation.setter(#defaultStatus, value),
          returnValueForMissingStub: null);
  @override
  set defaultstatus(String? value) =>
      super.noSuchMethod(Invocation.setter(#defaultstatus, value),
          returnValueForMissingStub: null);
  @override
  set defaultStatus(String? value) =>
      super.noSuchMethod(Invocation.setter(#defaultStatus, value),
          returnValueForMissingStub: null);
  @override
  set defaultstatus(String? value) =>
      super.noSuchMethod(Invocation.setter(#defaultstatus, value),
          returnValueForMissingStub: null);
  @override
  num get devicePixelRatio =>
      (super.noSuchMethod(Invocation.getter(#devicePixelRatio), returnValue: 0)
          as num);
  @override
  _i2.History get history => (super.noSuchMethod(Invocation.getter(#history),
      returnValue: _FakeHistory_3()) as _i2.History);
  @override
  _i2.Storage get localStorage =>
      (super.noSuchMethod(Invocation.getter(#localStorage),
          returnValue: _FakeStorage_4()) as _i2.Storage);
  @override
  set name(String? value) => super.noSuchMethod(Invocation.setter(#name, value),
      returnValueForMissingStub: null);
  @override
  set name(String? value) => super.noSuchMethod(Invocation.setter(#name, value),
      returnValueForMissingStub: null);
  @override
  _i2.Navigator get navigator =>
      (super.noSuchMethod(Invocation.getter(#navigator),
          returnValue: _FakeNavigator_5()) as _i2.Navigator);
  @override
  set opener(_i2.WindowBase? value) =>
      super.noSuchMethod(Invocation.setter(#opener, value),
          returnValueForMissingStub: null);
  @override
  set opener(_i2.WindowBase? value) =>
      super.noSuchMethod(Invocation.setter(#opener, value),
          returnValueForMissingStub: null);
  @override
  int get outerHeight =>
      (super.noSuchMethod(Invocation.getter(#outerHeight), returnValue: 0)
          as int);
  @override
  int get outerWidth =>
      (super.noSuchMethod(Invocation.getter(#outerWidth), returnValue: 0)
          as int);
  @override
  _i2.Performance get performance =>
      (super.noSuchMethod(Invocation.getter(#performance),
          returnValue: _FakePerformance_6()) as _i2.Performance);
  @override
  _i2.Storage get sessionStorage =>
      (super.noSuchMethod(Invocation.getter(#sessionStorage),
          returnValue: _FakeStorage_4()) as _i2.Storage);
  @override
  set status(String? value) =>
      super.noSuchMethod(Invocation.setter(#status, value),
          returnValueForMissingStub: null);
  @override

  _i3.Stream<_i2.Event> get onContentLoaded =>
      (super.noSuchMethod(Invocation.getter(#onContentLoaded),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onAbort =>
      (super.noSuchMethod(Invocation.getter(#onAbort),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onBlur =>
      (super.noSuchMethod(Invocation.getter(#onBlur),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onCanPlay =>
      (super.noSuchMethod(Invocation.getter(#onCanPlay),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onCanPlayThrough =>
      (super.noSuchMethod(Invocation.getter(#onCanPlayThrough),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onChange =>
      (super.noSuchMethod(Invocation.getter(#onChange),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.MouseEvent> get onClick =>
      (super.noSuchMethod(Invocation.getter(#onClick),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onContextMenu =>
      (super.noSuchMethod(Invocation.getter(#onContextMenu),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.Event> get onDoubleClick =>
      (super.noSuchMethod(Invocation.getter(#onDoubleClick),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.DeviceMotionEvent> get onDeviceMotion =>
      (super.noSuchMethod(Invocation.getter(#onDeviceMotion),
              returnValue: Stream<_i2.DeviceMotionEvent>.empty())
          as _i3.Stream<_i2.DeviceMotionEvent>);
  @override
  _i3.Stream<_i2.DeviceOrientationEvent> get onDeviceOrientation =>
      (super.noSuchMethod(Invocation.getter(#onDeviceOrientation),
              returnValue: Stream<_i2.DeviceOrientationEvent>.empty())
          as _i3.Stream<_i2.DeviceOrientationEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDrag =>
      (super.noSuchMethod(Invocation.getter(#onDrag),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDragEnd =>
      (super.noSuchMethod(Invocation.getter(#onDragEnd),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDragEnter =>
      (super.noSuchMethod(Invocation.getter(#onDragEnter),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDragLeave =>
      (super.noSuchMethod(Invocation.getter(#onDragLeave),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDragOver =>
      (super.noSuchMethod(Invocation.getter(#onDragOver),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDragStart =>
      (super.noSuchMethod(Invocation.getter(#onDragStart),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onDrop =>
      (super.noSuchMethod(Invocation.getter(#onDrop),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.Event> get onDurationChange =>
      (super.noSuchMethod(Invocation.getter(#onDurationChange),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onEmptied =>
      (super.noSuchMethod(Invocation.getter(#onEmptied),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onEnded =>
      (super.noSuchMethod(Invocation.getter(#onEnded),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onError =>
      (super.noSuchMethod(Invocation.getter(#onError),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onFocus =>
      (super.noSuchMethod(Invocation.getter(#onFocus),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onHashChange =>
      (super.noSuchMethod(Invocation.getter(#onHashChange),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onInput =>
      (super.noSuchMethod(Invocation.getter(#onInput),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onInvalid =>
      (super.noSuchMethod(Invocation.getter(#onInvalid),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.KeyboardEvent> get onKeyDown =>
      (super.noSuchMethod(Invocation.getter(#onKeyDown),
              returnValue: Stream<_i2.KeyboardEvent>.empty())
          as _i3.Stream<_i2.KeyboardEvent>);
  @override
  _i3.Stream<_i2.KeyboardEvent> get onKeyPress =>
      (super.noSuchMethod(Invocation.getter(#onKeyPress),
              returnValue: Stream<_i2.KeyboardEvent>.empty())
          as _i3.Stream<_i2.KeyboardEvent>);
  @override
  _i3.Stream<_i2.KeyboardEvent> get onKeyUp =>
      (super.noSuchMethod(Invocation.getter(#onKeyUp),
              returnValue: Stream<_i2.KeyboardEvent>.empty())
          as _i3.Stream<_i2.KeyboardEvent>);
  @override
  _i3.Stream<_i2.Event> get onLoad =>
      (super.noSuchMethod(Invocation.getter(#onLoad),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onLoadedData =>
      (super.noSuchMethod(Invocation.getter(#onLoadedData),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onLoadedMetadata =>
      (super.noSuchMethod(Invocation.getter(#onLoadedMetadata),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onLoadStart =>
      (super.noSuchMethod(Invocation.getter(#onLoadStart),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.MessageEvent> get onMessage =>
      (super.noSuchMethod(Invocation.getter(#onMessage),
              returnValue: Stream<_i2.MessageEvent>.empty())
          as _i3.Stream<_i2.MessageEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseDown =>
      (super.noSuchMethod(Invocation.getter(#onMouseDown),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseEnter =>
      (super.noSuchMethod(Invocation.getter(#onMouseEnter),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseLeave =>
      (super.noSuchMethod(Invocation.getter(#onMouseLeave),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseMove =>
      (super.noSuchMethod(Invocation.getter(#onMouseMove),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseOut =>
      (super.noSuchMethod(Invocation.getter(#onMouseOut),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseOver =>
      (super.noSuchMethod(Invocation.getter(#onMouseOver),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.MouseEvent> get onMouseUp =>
      (super.noSuchMethod(Invocation.getter(#onMouseUp),
              returnValue: Stream<_i2.MouseEvent>.empty())
          as _i3.Stream<_i2.MouseEvent>);
  @override
  _i3.Stream<_i2.WheelEvent> get onMouseWheel =>
      (super.noSuchMethod(Invocation.getter(#onMouseWheel),
              returnValue: Stream<_i2.WheelEvent>.empty())
          as _i3.Stream<_i2.WheelEvent>);
  @override
  _i3.Stream<_i2.Event> get onOffline =>
      (super.noSuchMethod(Invocation.getter(#onOffline),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onOnline =>
      (super.noSuchMethod(Invocation.getter(#onOnline),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onPageHide =>
      (super.noSuchMethod(Invocation.getter(#onPageHide),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onPageShow =>
      (super.noSuchMethod(Invocation.getter(#onPageShow),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onPause =>
      (super.noSuchMethod(Invocation.getter(#onPause),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onPlay =>
      (super.noSuchMethod(Invocation.getter(#onPlay),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onPlaying =>
      (super.noSuchMethod(Invocation.getter(#onPlaying),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.PopStateEvent> get onPopState =>
      (super.noSuchMethod(Invocation.getter(#onPopState),
              returnValue: Stream<_i2.PopStateEvent>.empty())
          as _i3.Stream<_i2.PopStateEvent>);
  @override
  _i3.Stream<_i2.Event> get onProgress =>
      (super.noSuchMethod(Invocation.getter(#onProgress),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onRateChange =>
      (super.noSuchMethod(Invocation.getter(#onRateChange),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onReset =>
      (super.noSuchMethod(Invocation.getter(#onReset),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onResize =>
      (super.noSuchMethod(Invocation.getter(#onResize),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onScroll =>
      (super.noSuchMethod(Invocation.getter(#onScroll),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onSearch =>
      (super.noSuchMethod(Invocation.getter(#onSearch),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onSeeked =>
      (super.noSuchMethod(Invocation.getter(#onSeeked),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onSeeking =>
      (super.noSuchMethod(Invocation.getter(#onSeeking),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onSelect =>
      (super.noSuchMethod(Invocation.getter(#onSelect),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onStalled =>
      (super.noSuchMethod(Invocation.getter(#onStalled),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.StorageEvent> get onStorage =>
      (super.noSuchMethod(Invocation.getter(#onStorage),
              returnValue: Stream<_i2.StorageEvent>.empty())
          as _i3.Stream<_i2.StorageEvent>);
  @override
  _i3.Stream<_i2.Event> get onSubmit =>
      (super.noSuchMethod(Invocation.getter(#onSubmit),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onSuspend =>
      (super.noSuchMethod(Invocation.getter(#onSuspend),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onTimeUpdate =>
      (super.noSuchMethod(Invocation.getter(#onTimeUpdate),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.TouchEvent> get onTouchCancel =>
      (super.noSuchMethod(Invocation.getter(#onTouchCancel),
              returnValue: Stream<_i2.TouchEvent>.empty())
          as _i3.Stream<_i2.TouchEvent>);
  @override
  _i3.Stream<_i2.TouchEvent> get onTouchEnd =>
      (super.noSuchMethod(Invocation.getter(#onTouchEnd),
              returnValue: Stream<_i2.TouchEvent>.empty())
          as _i3.Stream<_i2.TouchEvent>);
  @override
  _i3.Stream<_i2.TouchEvent> get onTouchMove =>
      (super.noSuchMethod(Invocation.getter(#onTouchMove),
              returnValue: Stream<_i2.TouchEvent>.empty())
          as _i3.Stream<_i2.TouchEvent>);
  @override
  _i3.Stream<_i2.TouchEvent> get onTouchStart =>
      (super.noSuchMethod(Invocation.getter(#onTouchStart),
              returnValue: Stream<_i2.TouchEvent>.empty())
          as _i3.Stream<_i2.TouchEvent>);
  @override
  _i3.Stream<_i2.TransitionEvent> get onTransitionEnd =>
      (super.noSuchMethod(Invocation.getter(#onTransitionEnd),
              returnValue: Stream<_i2.TransitionEvent>.empty())
          as _i3.Stream<_i2.TransitionEvent>);
  @override
  _i3.Stream<_i2.Event> get onUnload =>
      (super.noSuchMethod(Invocation.getter(#onUnload),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onVolumeChange =>
      (super.noSuchMethod(Invocation.getter(#onVolumeChange),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.Event> get onWaiting =>
      (super.noSuchMethod(Invocation.getter(#onWaiting),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.AnimationEvent> get onAnimationEnd =>
      (super.noSuchMethod(Invocation.getter(#onAnimationEnd),
              returnValue: Stream<_i2.AnimationEvent>.empty())
          as _i3.Stream<_i2.AnimationEvent>);
  @override
  _i3.Stream<_i2.AnimationEvent> get onAnimationIteration =>
      (super.noSuchMethod(Invocation.getter(#onAnimationIteration),
              returnValue: Stream<_i2.AnimationEvent>.empty())
          as _i3.Stream<_i2.AnimationEvent>);
  @override
  _i3.Stream<_i2.AnimationEvent> get onAnimationStart =>
      (super.noSuchMethod(Invocation.getter(#onAnimationStart),
              returnValue: Stream<_i2.AnimationEvent>.empty())
          as _i3.Stream<_i2.AnimationEvent>);
  @override
  _i3.Stream<_i2.Event> get onBeforeUnload =>
      (super.noSuchMethod(Invocation.getter(#onBeforeUnload),
          returnValue: Stream<_i2.Event>.empty()) as _i3.Stream<_i2.Event>);
  @override
  _i3.Stream<_i2.WheelEvent> get onWheel =>
      (super.noSuchMethod(Invocation.getter(#onWheel),
              returnValue: Stream<_i2.WheelEvent>.empty())
          as _i3.Stream<_i2.WheelEvent>);
  @override
  int get pageXOffset =>
      (super.noSuchMethod(Invocation.getter(#pageXOffset), returnValue: 0)
          as int);
  @override
  int get pageYOffset =>
      (super.noSuchMethod(Invocation.getter(#pageYOffset), returnValue: 0)
          as int);
  @override
  int get scrollX =>
      (super.noSuchMethod(Invocation.getter(#scrollX), returnValue: 0) as int);
  @override
  int get scrollY =>
      (super.noSuchMethod(Invocation.getter(#scrollY), returnValue: 0) as int);
  @override
  _i2.Events get on =>
      (super.noSuchMethod(Invocation.getter(#on), returnValue: _FakeEvents_7())
          as _i2.Events);
  @override
  _i2.WindowBase open(String? url, String? name, [String? options]) =>
      (super.noSuchMethod(Invocation.method(#open, [url, name, options]),
          returnValue: _FakeWindowBase_8()) as _i2.WindowBase);
  @override
  int requestAnimationFrame(_i2.FrameRequestCallback? callback) =>
      (super.noSuchMethod(Invocation.method(#requestAnimationFrame, [callback]),
          returnValue: 0) as int);
  @override
  void cancelAnimationFrame(int? id) =>
      super.noSuchMethod(Invocation.method(#cancelAnimationFrame, [id]),
          returnValueForMissingStub: null);
  @override
  _i3.Future<_i2.FileSystem> requestFileSystem(int? size,
          {bool? persistent = false}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #requestFileSystem, [size], {#persistent: persistent}),

              returnValue: Future<_i2.FileSystem>.value(_FakeFileSystem_9()))
          as _i3.Future<_i2.FileSystem>);
  @override
  void alert([String? message]) =>
      super.noSuchMethod(Invocation.method(#alert, [message]),
          returnValueForMissingStub: null);
  @override
  void alert([String? message]) =>
      super.noSuchMethod(Invocation.method(#alert, [message]),
          returnValueForMissingStub: null);
  @override
  void cancelIdleCallback(int? handle) =>
      super.noSuchMethod(Invocation.method(#cancelIdleCallback, [handle]),
          returnValueForMissingStub: null);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
  @override
  bool confirm([String? message]) =>
      (super.noSuchMethod(Invocation.method(#confirm, [message]),
          returnValue: false) as bool);
  @override
  _i3.Future<dynamic> fetch(dynamic input, [Map<dynamic, dynamic>? init]) =>
      (super.noSuchMethod(Invocation.method(#fetch, [input, init]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  bool find(String? string, bool? caseSensitive, bool? backwards, bool? wrap,
          bool? wholeWord, bool? searchInFrames, bool? showDialog) =>
      (super.noSuchMethod(
          Invocation.method(#find, [
            string,
            caseSensitive,
            backwards,
            wrap,
            wholeWord,
            searchInFrames,
            showDialog
          ]),
          returnValue: false) as bool);
  @override
  _i2.StylePropertyMapReadonly getComputedStyleMap(
          _i2.Element? element, String? pseudoElement) =>
      (super.noSuchMethod(
              Invocation.method(#getComputedStyleMap, [element, pseudoElement]),
              returnValue: _FakeStylePropertyMapReadonly_10())
          as _i2.StylePropertyMapReadonly);
  @override
  List<_i2.CssRule> getMatchedCssRules(
          _i2.Element? element, String? pseudoElement) =>
      (super.noSuchMethod(
          Invocation.method(#getMatchedCssRules, [element, pseudoElement]),
          returnValue: <_i2.CssRule>[]) as List<_i2.CssRule>);
  @override
  _i2.MediaQueryList matchMedia(String? query) =>
      (super.noSuchMethod(Invocation.method(#matchMedia, [query]),
          returnValue: _FakeMediaQueryList_11()) as _i2.MediaQueryList);
  @override
  void moveBy(int? x, int? y) =>
      super.noSuchMethod(Invocation.method(#moveBy, [x, y]),
          returnValueForMissingStub: null);
  @override
  void postMessage(dynamic message, String? targetOrigin,
          [List<Object>? transfer]) =>
      super.noSuchMethod(
          Invocation.method(#postMessage, [message, targetOrigin, transfer]),
          returnValueForMissingStub: null);
  @override
  void print() => super.noSuchMethod(Invocation.method(#print, []),
      returnValueForMissingStub: null);
  @override
  int requestIdleCallback(_i2.IdleRequestCallback? callback,
          [Map<dynamic, dynamic>? options]) =>
      (super.noSuchMethod(
          Invocation.method(#requestIdleCallback, [callback, options]),
          returnValue: 0) as int);
  @override
  void resizeBy(int? x, int? y) =>
      super.noSuchMethod(Invocation.method(#resizeBy, [x, y]),
          returnValueForMissingStub: null);
  @override
  void resizeTo(int? x, int? y) =>
      super.noSuchMethod(Invocation.method(#resizeTo, [x, y]),
          returnValueForMissingStub: null);
  @override
  void scroll(
          [dynamic options_OR_x,
          dynamic y,
          Map<dynamic, dynamic>? scrollOptions]) =>
      super.noSuchMethod(
          Invocation.method(#scroll, [options_OR_x, y, scrollOptions]),
          returnValueForMissingStub: null);
  @override
  void scrollBy(
          [dynamic options_OR_x,
          dynamic y,
          Map<dynamic, dynamic>? scrollOptions]) =>
      super.noSuchMethod(
          Invocation.method(#scrollBy, [options_OR_x, y, scrollOptions]),
          returnValueForMissingStub: null);
  @override
  void scrollTo(
          [dynamic options_OR_x,
          dynamic y,
          Map<dynamic, dynamic>? scrollOptions]) =>
      super.noSuchMethod(
          Invocation.method(#scrollTo, [options_OR_x, y, scrollOptions]),
          returnValueForMissingStub: null);
  @override
  void stop() => super.noSuchMethod(Invocation.method(#stop, []),
      returnValueForMissingStub: null);
  @override
  _i3.Future<_i2.Entry> resolveLocalFileSystemUrl(String? url) =>
      (super.noSuchMethod(Invocation.method(#resolveLocalFileSystemUrl, [url]),
              returnValue: Future<_i2.Entry>.value(_FakeEntry_12()))
          as _i3.Future<_i2.Entry>);
  @override
  String atob(String? atob) =>
      (super.noSuchMethod(Invocation.method(#atob, [atob]), returnValue: '')
          as String);
  @override
  String btoa(String? btoa) =>
      (super.noSuchMethod(Invocation.method(#btoa, [btoa]), returnValue: '')
          as String);
  @override
  void moveTo(_i4.Point<num>? p) =>
      super.noSuchMethod(Invocation.method(#moveTo, [p]),
          returnValueForMissingStub: null);
  @override
  void addEventListener(String? type, _i2.EventListener? listener,
          [bool? useCapture]) =>
      super.noSuchMethod(
          Invocation.method(#addEventListener, [type, listener, useCapture]),
          returnValueForMissingStub: null);
  @override
  void removeEventListener(String? type, _i2.EventListener? listener,
          [bool? useCapture]) =>
      super.noSuchMethod(
          Invocation.method(#removeEventListener, [type, listener, useCapture]),
          returnValueForMissingStub: null);
  @override
  bool dispatchEvent(_i2.Event? event) =>
      (super.noSuchMethod(Invocation.method(#dispatchEvent, [event]),
          returnValue: false) as bool);
  @override
  String toString() => super.toString();
}

/// A class which mocks [Navigator].
///
/// See the documentation for Mockito's code generation for more information.
class MockNavigator extends _i1.Mock implements _i2.Navigator {
  MockNavigator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get language =>
      (super.noSuchMethod(Invocation.getter(#language), returnValue: '')
          as String);
  @override
  _i2.Geolocation get geolocation =>
      (super.noSuchMethod(Invocation.getter(#geolocation),
          returnValue: _FakeGeolocation_13()) as _i2.Geolocation);
  @override
  String get vendor =>
      (super.noSuchMethod(Invocation.getter(#vendor), returnValue: '')
          as String);
  @override
  String get vendorSub =>
      (super.noSuchMethod(Invocation.getter(#vendorSub), returnValue: '')
          as String);
  @override
  String get appCodeName =>
      (super.noSuchMethod(Invocation.getter(#appCodeName), returnValue: '')
          as String);
  @override
  String get appName =>
      (super.noSuchMethod(Invocation.getter(#appName), returnValue: '')
          as String);
  @override
  String get appVersion =>
      (super.noSuchMethod(Invocation.getter(#appVersion), returnValue: '')
          as String);
  @override
  String get product =>
      (super.noSuchMethod(Invocation.getter(#product), returnValue: '')
          as String);
  @override
  String get userAgent =>
      (super.noSuchMethod(Invocation.getter(#userAgent), returnValue: '')
          as String);
  @override
  List<_i2.Gamepad?> getGamepads() =>
      (super.noSuchMethod(Invocation.method(#getGamepads, []),
          returnValue: <_i2.Gamepad?>[]) as List<_i2.Gamepad?>);
  @override
  _i3.Future<_i2.MediaStream> getUserMedia(
          {dynamic audio = false, dynamic video = false}) =>
      (super.noSuchMethod(
          Invocation.method(#getUserMedia, [], {#audio: audio, #video: video}),
          returnValue:
              Future<_i2.MediaStream>.value(_FakeMediaStream_14())) as _i3
          .Future<_i2.MediaStream>);
  @override
  void cancelKeyboardLock() =>
      super.noSuchMethod(Invocation.method(#cancelKeyboardLock, []),
          returnValueForMissingStub: null);
  @override
  _i3.Future<dynamic> getBattery() =>
      (super.noSuchMethod(Invocation.method(#getBattery, []),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<_i2.RelatedApplication> getInstalledRelatedApps() =>
      (super.noSuchMethod(Invocation.method(#getInstalledRelatedApps, []),
              returnValue: Future<_i2.RelatedApplication>.value(
                  _FakeRelatedApplication_15()))
          as _i3.Future<_i2.RelatedApplication>);
  @override
  _i3.Future<dynamic> getVRDisplays() =>
      (super.noSuchMethod(Invocation.method(#getVRDisplays, []),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  void registerProtocolHandler(String? scheme, String? url, String? title) =>
      super.noSuchMethod(
          Invocation.method(#registerProtocolHandler, [scheme, url, title]),
          returnValueForMissingStub: null);
  @override
  _i3.Future<dynamic> requestKeyboardLock([List<String>? keyCodes]) =>
      (super.noSuchMethod(Invocation.method(#requestKeyboardLock, [keyCodes]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> requestMidiAccess([Map<dynamic, dynamic>? options]) =>
      (super.noSuchMethod(Invocation.method(#requestMidiAccess, [options]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> requestMediaKeySystemAccess(String? keySystem,
          List<Map<dynamic, dynamic>>? supportedConfigurations) =>
      (super.noSuchMethod(
          Invocation.method(#requestMediaKeySystemAccess,
              [keySystem, supportedConfigurations]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  bool sendBeacon(String? url, Object? data) =>
      (super.noSuchMethod(Invocation.method(#sendBeacon, [url, data]),
          returnValue: false) as bool);
  @override
  _i3.Future<dynamic> share([Map<dynamic, dynamic>? data]) =>
      (super.noSuchMethod(Invocation.method(#share, [data]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  String toString() => super.toString();
}
