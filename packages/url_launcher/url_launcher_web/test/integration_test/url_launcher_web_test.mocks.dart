import 'dart:async' as _i4;
import 'dart:html' as _i2;
import 'dart:math' as _i5;

import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: comment_references

// ignore_for_file: unnecessary_parenthesis

// ignore_for_file: extra_positional_arguments_could_be_named

class _FakeDocument extends _i1.Fake implements _i2.Document {}

class _FakeLocation extends _i1.Fake implements _i2.Location {}

class _FakeConsole extends _i1.Fake implements _i2.Console {}

class _FakeHistory extends _i1.Fake implements _i2.History {}

class _FakeStorage extends _i1.Fake implements _i2.Storage {}

class _FakeNavigator extends _i1.Fake implements _i2.Navigator {}

class _FakePerformance extends _i1.Fake implements _i2.Performance {}

class _FakeEvents extends _i1.Fake implements _i2.Events {}

class _FakeType extends _i1.Fake implements Type {}

class _FakeWindowBase extends _i1.Fake implements _i2.WindowBase {}

class _FakeFileSystem extends _i1.Fake implements _i2.FileSystem {}

class _FakeStylePropertyMapReadonly extends _i1.Fake
    implements _i2.StylePropertyMapReadonly {}

class _FakeMediaQueryList extends _i1.Fake implements _i2.MediaQueryList {}

class _FakeEntry extends _i1.Fake implements _i2.Entry {}

class _FakeGeolocation extends _i1.Fake implements _i2.Geolocation {}

class _FakeMediaStream extends _i1.Fake implements _i2.MediaStream {}

class _FakeRelatedApplication extends _i1.Fake
    implements _i2.RelatedApplication {}

/// A class which mocks [Window].
///
/// See the documentation for Mockito's code generation for more information.
class MockWindow extends _i1.Mock implements _i2.Window {
  MockWindow() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<num> get animationFrame =>
      (super.noSuchMethod(Invocation.getter(#animationFrame), Future.value(0))
          as _i4.Future<num>);
  @override
  _i2.Document get document =>
      (super.noSuchMethod(Invocation.getter(#document), _FakeDocument())
          as _i2.Document);
  @override
  _i2.Location get location =>
      (super.noSuchMethod(Invocation.getter(#location), _FakeLocation())
          as _i2.Location);
  @override
  set location(_i2.LocationBase? value) =>
      super.noSuchMethod(Invocation.setter(#location, value));
  @override
  _i2.Console get console =>
      (super.noSuchMethod(Invocation.getter(#console), _FakeConsole())
          as _i2.Console);
  @override
  num get devicePixelRatio =>
      (super.noSuchMethod(Invocation.getter(#devicePixelRatio), 0) as num);
  @override
  _i2.History get history =>
      (super.noSuchMethod(Invocation.getter(#history), _FakeHistory())
          as _i2.History);
  @override
  _i2.Storage get localStorage =>
      (super.noSuchMethod(Invocation.getter(#localStorage), _FakeStorage())
          as _i2.Storage);
  @override
  _i2.Navigator get navigator =>
      (super.noSuchMethod(Invocation.getter(#navigator), _FakeNavigator())
          as _i2.Navigator);
  @override
  int get outerHeight =>
      (super.noSuchMethod(Invocation.getter(#outerHeight), 0) as int);
  @override
  int get outerWidth =>
      (super.noSuchMethod(Invocation.getter(#outerWidth), 0) as int);
  @override
  _i2.Performance get performance =>
      (super.noSuchMethod(Invocation.getter(#performance), _FakePerformance())
          as _i2.Performance);
  @override
  _i2.Storage get sessionStorage =>
      (super.noSuchMethod(Invocation.getter(#sessionStorage), _FakeStorage())
          as _i2.Storage);
  @override
  _i4.Stream<_i2.Event> get onContentLoaded => (super.noSuchMethod(
          Invocation.getter(#onContentLoaded), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onAbort => (super
          .noSuchMethod(Invocation.getter(#onAbort), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onBlur =>
      (super.noSuchMethod(Invocation.getter(#onBlur), Stream<_i2.Event>.empty())
          as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onCanPlay => (super.noSuchMethod(
          Invocation.getter(#onCanPlay), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onCanPlayThrough => (super.noSuchMethod(
          Invocation.getter(#onCanPlayThrough), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onChange => (super
          .noSuchMethod(Invocation.getter(#onChange), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.MouseEvent> get onClick => (super.noSuchMethod(
          Invocation.getter(#onClick), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onContextMenu => (super.noSuchMethod(
          Invocation.getter(#onContextMenu), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.Event> get onDoubleClick => (super.noSuchMethod(
          Invocation.getter(#onDoubleClick), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.DeviceMotionEvent> get onDeviceMotion => (super.noSuchMethod(
          Invocation.getter(#onDeviceMotion),
          Stream<_i2.DeviceMotionEvent>.empty())
      as _i4.Stream<_i2.DeviceMotionEvent>);
  @override
  _i4.Stream<_i2.DeviceOrientationEvent> get onDeviceOrientation =>
      (super.noSuchMethod(Invocation.getter(#onDeviceOrientation),
              Stream<_i2.DeviceOrientationEvent>.empty())
          as _i4.Stream<_i2.DeviceOrientationEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDrag => (super.noSuchMethod(
          Invocation.getter(#onDrag), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDragEnd => (super.noSuchMethod(
          Invocation.getter(#onDragEnd), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDragEnter => (super.noSuchMethod(
          Invocation.getter(#onDragEnter), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDragLeave => (super.noSuchMethod(
          Invocation.getter(#onDragLeave), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDragOver => (super.noSuchMethod(
          Invocation.getter(#onDragOver), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDragStart => (super.noSuchMethod(
          Invocation.getter(#onDragStart), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onDrop => (super.noSuchMethod(
          Invocation.getter(#onDrop), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.Event> get onDurationChange => (super.noSuchMethod(
          Invocation.getter(#onDurationChange), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onEmptied => (super.noSuchMethod(
          Invocation.getter(#onEmptied), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onEnded => (super
          .noSuchMethod(Invocation.getter(#onEnded), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onError => (super
          .noSuchMethod(Invocation.getter(#onError), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onFocus => (super
          .noSuchMethod(Invocation.getter(#onFocus), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onHashChange => (super.noSuchMethod(
          Invocation.getter(#onHashChange), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onInput => (super
          .noSuchMethod(Invocation.getter(#onInput), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onInvalid => (super.noSuchMethod(
          Invocation.getter(#onInvalid), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.KeyboardEvent> get onKeyDown => (super.noSuchMethod(
          Invocation.getter(#onKeyDown), Stream<_i2.KeyboardEvent>.empty())
      as _i4.Stream<_i2.KeyboardEvent>);
  @override
  _i4.Stream<_i2.KeyboardEvent> get onKeyPress => (super.noSuchMethod(
          Invocation.getter(#onKeyPress), Stream<_i2.KeyboardEvent>.empty())
      as _i4.Stream<_i2.KeyboardEvent>);
  @override
  _i4.Stream<_i2.KeyboardEvent> get onKeyUp => (super.noSuchMethod(
          Invocation.getter(#onKeyUp), Stream<_i2.KeyboardEvent>.empty())
      as _i4.Stream<_i2.KeyboardEvent>);
  @override
  _i4.Stream<_i2.Event> get onLoad =>
      (super.noSuchMethod(Invocation.getter(#onLoad), Stream<_i2.Event>.empty())
          as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onLoadedData => (super.noSuchMethod(
          Invocation.getter(#onLoadedData), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onLoadedMetadata => (super.noSuchMethod(
          Invocation.getter(#onLoadedMetadata), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onLoadStart => (super.noSuchMethod(
          Invocation.getter(#onLoadStart), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.MessageEvent> get onMessage => (super.noSuchMethod(
          Invocation.getter(#onMessage), Stream<_i2.MessageEvent>.empty())
      as _i4.Stream<_i2.MessageEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseDown => (super.noSuchMethod(
          Invocation.getter(#onMouseDown), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseEnter => (super.noSuchMethod(
          Invocation.getter(#onMouseEnter), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseLeave => (super.noSuchMethod(
          Invocation.getter(#onMouseLeave), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseMove => (super.noSuchMethod(
          Invocation.getter(#onMouseMove), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseOut => (super.noSuchMethod(
          Invocation.getter(#onMouseOut), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseOver => (super.noSuchMethod(
          Invocation.getter(#onMouseOver), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.MouseEvent> get onMouseUp => (super.noSuchMethod(
          Invocation.getter(#onMouseUp), Stream<_i2.MouseEvent>.empty())
      as _i4.Stream<_i2.MouseEvent>);
  @override
  _i4.Stream<_i2.WheelEvent> get onMouseWheel => (super.noSuchMethod(
          Invocation.getter(#onMouseWheel), Stream<_i2.WheelEvent>.empty())
      as _i4.Stream<_i2.WheelEvent>);
  @override
  _i4.Stream<_i2.Event> get onOffline => (super.noSuchMethod(
          Invocation.getter(#onOffline), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onOnline => (super
          .noSuchMethod(Invocation.getter(#onOnline), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onPageHide => (super.noSuchMethod(
          Invocation.getter(#onPageHide), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onPageShow => (super.noSuchMethod(
          Invocation.getter(#onPageShow), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onPause => (super
          .noSuchMethod(Invocation.getter(#onPause), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onPlay =>
      (super.noSuchMethod(Invocation.getter(#onPlay), Stream<_i2.Event>.empty())
          as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onPlaying => (super.noSuchMethod(
          Invocation.getter(#onPlaying), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.PopStateEvent> get onPopState => (super.noSuchMethod(
          Invocation.getter(#onPopState), Stream<_i2.PopStateEvent>.empty())
      as _i4.Stream<_i2.PopStateEvent>);
  @override
  _i4.Stream<_i2.Event> get onProgress => (super.noSuchMethod(
          Invocation.getter(#onProgress), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onRateChange => (super.noSuchMethod(
          Invocation.getter(#onRateChange), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onReset => (super
          .noSuchMethod(Invocation.getter(#onReset), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onResize => (super
          .noSuchMethod(Invocation.getter(#onResize), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onScroll => (super
          .noSuchMethod(Invocation.getter(#onScroll), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onSearch => (super
          .noSuchMethod(Invocation.getter(#onSearch), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onSeeked => (super
          .noSuchMethod(Invocation.getter(#onSeeked), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onSeeking => (super.noSuchMethod(
          Invocation.getter(#onSeeking), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onSelect => (super
          .noSuchMethod(Invocation.getter(#onSelect), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onStalled => (super.noSuchMethod(
          Invocation.getter(#onStalled), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.StorageEvent> get onStorage => (super.noSuchMethod(
          Invocation.getter(#onStorage), Stream<_i2.StorageEvent>.empty())
      as _i4.Stream<_i2.StorageEvent>);
  @override
  _i4.Stream<_i2.Event> get onSubmit => (super
          .noSuchMethod(Invocation.getter(#onSubmit), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onSuspend => (super.noSuchMethod(
          Invocation.getter(#onSuspend), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onTimeUpdate => (super.noSuchMethod(
          Invocation.getter(#onTimeUpdate), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.TouchEvent> get onTouchCancel => (super.noSuchMethod(
          Invocation.getter(#onTouchCancel), Stream<_i2.TouchEvent>.empty())
      as _i4.Stream<_i2.TouchEvent>);
  @override
  _i4.Stream<_i2.TouchEvent> get onTouchEnd => (super.noSuchMethod(
          Invocation.getter(#onTouchEnd), Stream<_i2.TouchEvent>.empty())
      as _i4.Stream<_i2.TouchEvent>);
  @override
  _i4.Stream<_i2.TouchEvent> get onTouchMove => (super.noSuchMethod(
          Invocation.getter(#onTouchMove), Stream<_i2.TouchEvent>.empty())
      as _i4.Stream<_i2.TouchEvent>);
  @override
  _i4.Stream<_i2.TouchEvent> get onTouchStart => (super.noSuchMethod(
          Invocation.getter(#onTouchStart), Stream<_i2.TouchEvent>.empty())
      as _i4.Stream<_i2.TouchEvent>);
  @override
  _i4.Stream<_i2.TransitionEvent> get onTransitionEnd => (super.noSuchMethod(
      Invocation.getter(#onTransitionEnd),
      Stream<_i2.TransitionEvent>.empty()) as _i4.Stream<_i2.TransitionEvent>);
  @override
  _i4.Stream<_i2.Event> get onUnload => (super
          .noSuchMethod(Invocation.getter(#onUnload), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onVolumeChange => (super.noSuchMethod(
          Invocation.getter(#onVolumeChange), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.Event> get onWaiting => (super.noSuchMethod(
          Invocation.getter(#onWaiting), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.AnimationEvent> get onAnimationEnd => (super.noSuchMethod(
      Invocation.getter(#onAnimationEnd),
      Stream<_i2.AnimationEvent>.empty()) as _i4.Stream<_i2.AnimationEvent>);
  @override
  _i4.Stream<_i2.AnimationEvent> get onAnimationIteration =>
      (super.noSuchMethod(Invocation.getter(#onAnimationIteration),
              Stream<_i2.AnimationEvent>.empty())
          as _i4.Stream<_i2.AnimationEvent>);
  @override
  _i4.Stream<_i2.AnimationEvent> get onAnimationStart => (super.noSuchMethod(
      Invocation.getter(#onAnimationStart),
      Stream<_i2.AnimationEvent>.empty()) as _i4.Stream<_i2.AnimationEvent>);
  @override
  _i4.Stream<_i2.Event> get onBeforeUnload => (super.noSuchMethod(
          Invocation.getter(#onBeforeUnload), Stream<_i2.Event>.empty())
      as _i4.Stream<_i2.Event>);
  @override
  _i4.Stream<_i2.WheelEvent> get onWheel => (super.noSuchMethod(
          Invocation.getter(#onWheel), Stream<_i2.WheelEvent>.empty())
      as _i4.Stream<_i2.WheelEvent>);
  @override
  int get pageXOffset =>
      (super.noSuchMethod(Invocation.getter(#pageXOffset), 0) as int);
  @override
  int get pageYOffset =>
      (super.noSuchMethod(Invocation.getter(#pageYOffset), 0) as int);
  @override
  int get scrollX =>
      (super.noSuchMethod(Invocation.getter(#scrollX), 0) as int);
  @override
  int get scrollY =>
      (super.noSuchMethod(Invocation.getter(#scrollY), 0) as int);
  @override
  _i2.Events get on =>
      (super.noSuchMethod(Invocation.getter(#on), _FakeEvents()) as _i2.Events);
  @override
  int get hashCode =>
      (super.noSuchMethod(Invocation.getter(#hashCode), 0) as int);
  @override
  Type get runtimeType =>
      (super.noSuchMethod(Invocation.getter(#runtimeType), _FakeType())
          as Type);
  @override
  _i2.WindowBase open(String? url, String? name, [String? options]) =>
      (super.noSuchMethod(
              Invocation.method(#open, [url, name, options]), _FakeWindowBase())
          as _i2.WindowBase);
  @override
  int requestAnimationFrame(_i2.FrameRequestCallback? callback) =>
      (super.noSuchMethod(
          Invocation.method(#requestAnimationFrame, [callback]), 0) as int);
  @override
  void cancelAnimationFrame(int? id) =>
      super.noSuchMethod(Invocation.method(#cancelAnimationFrame, [id]));
  @override
  _i4.Future<_i2.FileSystem> requestFileSystem(int? size, {bool? persistent}) =>
      (super.noSuchMethod(
          Invocation.method(
              #requestFileSystem, [size], {#persistent: persistent}),
          Future.value(_FakeFileSystem())) as _i4.Future<_i2.FileSystem>);
  @override
  void cancelIdleCallback(int? handle) =>
      super.noSuchMethod(Invocation.method(#cancelIdleCallback, [handle]));
  @override
  bool confirm([String? message]) =>
      (super.noSuchMethod(Invocation.method(#confirm, [message]), false)
          as bool);
  @override
  _i4.Future<dynamic> fetch(dynamic input, [Map<dynamic, dynamic>? init]) =>
      (super.noSuchMethod(
              Invocation.method(#fetch, [input, init]), Future.value(null))
          as _i4.Future<dynamic>);
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
          false) as bool);
  @override
  _i2.StylePropertyMapReadonly getComputedStyleMap(
          _i2.Element? element, String? pseudoElement) =>
      (super.noSuchMethod(
          Invocation.method(#getComputedStyleMap, [element, pseudoElement]),
          _FakeStylePropertyMapReadonly()) as _i2.StylePropertyMapReadonly);
  @override
  List<_i2.CssRule> getMatchedCssRules(
          _i2.Element? element, String? pseudoElement) =>
      (super.noSuchMethod(
          Invocation.method(#getMatchedCssRules, [element, pseudoElement]),
          <_i2.CssRule>[]) as List<_i2.CssRule>);
  @override
  _i2.MediaQueryList matchMedia(String? query) => (super.noSuchMethod(
          Invocation.method(#matchMedia, [query]), _FakeMediaQueryList())
      as _i2.MediaQueryList);
  @override
  void moveBy(int? x, int? y) =>
      super.noSuchMethod(Invocation.method(#moveBy, [x, y]));
  @override
  void postMessage(dynamic message, String? targetOrigin,
          [List<Object>? transfer]) =>
      super.noSuchMethod(
          Invocation.method(#postMessage, [message, targetOrigin, transfer]));
  @override
  int requestIdleCallback(_i2.IdleRequestCallback? callback,
          [Map<dynamic, dynamic>? options]) =>
      (super.noSuchMethod(
              Invocation.method(#requestIdleCallback, [callback, options]), 0)
          as int);
  @override
  void resizeBy(int? x, int? y) =>
      super.noSuchMethod(Invocation.method(#resizeBy, [x, y]));
  @override
  void resizeTo(int? x, int? y) =>
      super.noSuchMethod(Invocation.method(#resizeTo, [x, y]));
  @override
  _i4.Future<_i2.Entry> resolveLocalFileSystemUrl(String? url) =>
      (super.noSuchMethod(Invocation.method(#resolveLocalFileSystemUrl, [url]),
          Future.value(_FakeEntry())) as _i4.Future<_i2.Entry>);
  @override
  String atob(String? atob) =>
      (super.noSuchMethod(Invocation.method(#atob, [atob]), '') as String);
  @override
  String btoa(String? btoa) =>
      (super.noSuchMethod(Invocation.method(#btoa, [btoa]), '') as String);
  @override
  void moveTo(_i5.Point<num>? p) =>
      super.noSuchMethod(Invocation.method(#moveTo, [p]));
  @override
  void addEventListener(String? type, _i2.EventListener? listener,
          [bool? useCapture]) =>
      super.noSuchMethod(
          Invocation.method(#addEventListener, [type, listener, useCapture]));
  @override
  void removeEventListener(String? type, _i2.EventListener? listener,
          [bool? useCapture]) =>
      super.noSuchMethod(Invocation.method(
          #removeEventListener, [type, listener, useCapture]));
  @override
  bool dispatchEvent(_i2.Event? event) =>
      (super.noSuchMethod(Invocation.method(#dispatchEvent, [event]), false)
          as bool);
  @override
  bool operator ==(Object? other) =>
      (super.noSuchMethod(Invocation.method(#==, [other]), false) as bool);
  @override
  String toString() =>
      (super.noSuchMethod(Invocation.method(#toString, []), '') as String);
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
      (super.noSuchMethod(Invocation.getter(#language), '') as String);
  @override
  _i2.Geolocation get geolocation =>
      (super.noSuchMethod(Invocation.getter(#geolocation), _FakeGeolocation())
          as _i2.Geolocation);
  @override
  String get vendor =>
      (super.noSuchMethod(Invocation.getter(#vendor), '') as String);
  @override
  String get vendorSub =>
      (super.noSuchMethod(Invocation.getter(#vendorSub), '') as String);
  @override
  String get appCodeName =>
      (super.noSuchMethod(Invocation.getter(#appCodeName), '') as String);
  @override
  String get appName =>
      (super.noSuchMethod(Invocation.getter(#appName), '') as String);
  @override
  String get appVersion =>
      (super.noSuchMethod(Invocation.getter(#appVersion), '') as String);
  @override
  String get product =>
      (super.noSuchMethod(Invocation.getter(#product), '') as String);
  @override
  String get userAgent =>
      (super.noSuchMethod(Invocation.getter(#userAgent), '') as String);
  @override
  int get hashCode =>
      (super.noSuchMethod(Invocation.getter(#hashCode), 0) as int);
  @override
  Type get runtimeType =>
      (super.noSuchMethod(Invocation.getter(#runtimeType), _FakeType())
          as Type);
  @override
  List<_i2.Gamepad?> getGamepads() =>
      (super.noSuchMethod(Invocation.method(#getGamepads, []), <_i2.Gamepad?>[])
          as List<_i2.Gamepad?>);
  @override
  _i4.Future<_i2.MediaStream> getUserMedia({dynamic audio, dynamic video}) =>
      (super.noSuchMethod(
          Invocation.method(#getUserMedia, [], {#audio: audio, #video: video}),
          Future.value(_FakeMediaStream())) as _i4.Future<_i2.MediaStream>);
  @override
  _i4.Future<dynamic> getBattery() => (super
          .noSuchMethod(Invocation.method(#getBattery, []), Future.value(null))
      as _i4.Future<dynamic>);
  @override
  _i4.Future<_i2.RelatedApplication> getInstalledRelatedApps() =>
      (super.noSuchMethod(Invocation.method(#getInstalledRelatedApps, []),
              Future.value(_FakeRelatedApplication()))
          as _i4.Future<_i2.RelatedApplication>);
  @override
  _i4.Future<dynamic> getVRDisplays() => (super.noSuchMethod(
          Invocation.method(#getVRDisplays, []), Future.value(null))
      as _i4.Future<dynamic>);
  @override
  void registerProtocolHandler(String? scheme, String? url, String? title) =>
      super.noSuchMethod(
          Invocation.method(#registerProtocolHandler, [scheme, url, title]));
  @override
  _i4.Future<dynamic> requestKeyboardLock([List<String>? keyCodes]) =>
      (super.noSuchMethod(Invocation.method(#requestKeyboardLock, [keyCodes]),
          Future.value(null)) as _i4.Future<dynamic>);
  @override
  _i4.Future<dynamic> requestMidiAccess([Map<dynamic, dynamic>? options]) =>
      (super.noSuchMethod(Invocation.method(#requestMidiAccess, [options]),
          Future.value(null)) as _i4.Future<dynamic>);
  @override
  _i4.Future<dynamic> requestMediaKeySystemAccess(String? keySystem,
          List<Map<dynamic, dynamic>>? supportedConfigurations) =>
      (super.noSuchMethod(
          Invocation.method(#requestMediaKeySystemAccess,
              [keySystem, supportedConfigurations]),
          Future.value(null)) as _i4.Future<dynamic>);
  @override
  bool sendBeacon(String? url, Object? data) =>
      (super.noSuchMethod(Invocation.method(#sendBeacon, [url, data]), false)
          as bool);
  @override
  _i4.Future<dynamic> share([Map<dynamic, dynamic>? data]) =>
      (super.noSuchMethod(Invocation.method(#share, [data]), Future.value(null))
          as _i4.Future<dynamic>);
  @override
  bool operator ==(Object? other) =>
      (super.noSuchMethod(Invocation.method(#==, [other]), false) as bool);
  @override
  String toString() =>
      (super.noSuchMethod(Invocation.method(#toString, []), '') as String);
}
