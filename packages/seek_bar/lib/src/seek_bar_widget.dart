// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:seek_bar/seek_bar.dart';

/// A callback that formats a numeric value from a [SeekBar] widget.
///
/// See also:
///
///  * [SeekBar.semanticFormatterCallback], which shows an example use case.
typedef SemanticFormatterCallback = String Function(Duration value);

/// A Material Design seekBar.
///
/// Used to select from a range of values.
///
/// A seekBar can be used to select from either a continuous or a discrete set of
/// values. The default is to use a continuous range of values from [min] to
/// [max]. To use discrete values, use a non-null value for [divisions], which
/// indicates the number of discrete intervals. For example, if [min] is 0.0 and
/// [max] is 50.0 and [divisions] is 5, then the seekBar can take on the
/// discrete values 0.0, 10.0, 20.0, 30.0, 40.0, and 50.0.
///
/// The terms for the parts of a seekBar are:
///
///  * The "thumb", which is a shape that slides horizontally when the user
///    drags it.
///  * The "track", which is the line that the seekBar thumb slides along.
///  * The "value indicator", which is a shape that pops up when the user
///    is dragging the thumb to indicate the value being selected.
///  * The "active" side of the seekBar is the side between the thumb and the
///    minimum value.
///  * The "inactive" side of the seekBar is the side between the thumb and the
///    maximum value.
///  * The "buffer" sides of the seekBar are the sides present on the "inactive"
///    side to indicate the ranges presents in the buffer
///
/// The seekBar will be disabled if [onChanged] is null or if the range given by
/// [min]..[max] is empty (i.e. if [min] is equal to [max]).
///
/// The seekBar widget itself does not maintain any state. Instead, when the state
/// of the seekBar changes, the widget calls the [onChanged] callback. Most
/// widgets that use a seekBar will listen for the [onChanged] callback and
/// rebuild the seekBar with a new [value] to update the visual appearance of the
/// seekBar. To know when the value starts to change, or when it is done
/// changing, set the optional callbacks [onChangeStart] and/or [onChangeEnd].
///
/// By default, a seekBar will be as wide as possible, centered vertically. When
/// given unbounded constraints, it will attempt to make the track 144 pixels
/// wide (with margins on each side) and will shrink-wrap vertically.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// Requires one of its ancestors to be a [MediaQuery] widget. Typically, these
/// are introduced by the [MaterialApp] or [WidgetsApp] widget at the top of
/// your application widget tree.
///
/// To determine how it should be displayed (e.g. colors, thumb shape, etc.),
/// a seekBar uses the [SeekBarThemeData] available from either a [SeekBarTheme]
/// widget or the [ThemeData.seekBarTheme] a [Theme] widget above it in the
/// widget tree. You can also override some of the colors with the [playedColor]
/// and [backgroundColor] properties, although more fine-grained control of the
/// look is achieved using a [SeekBarThemeData].
///
/// See also:
///
///  * [SeekBarTheme] and [SeekBarThemeData] for information about controlling
///    the visual appearance of the seekBar.
///  * [Radio], for selecting among a set of explicit values.
///  * [Checkbox] and [Switch], for toggling a particular value on or off.
///  * <https://material.io/design/components/seekBars.html>
///  * [MediaQuery], from which the text scale factor is obtained.
class SeekBar extends StatefulWidget {
  /// Creates a material design seekBar.
  ///
  /// The seekBar itself does not maintain any state. Instead, when the state of
  /// the seekBar changes, the widget calls the [onChanged] callback. Most
  /// widgets that use a seekBar will listen for the [onChanged] callback and
  /// rebuild the seekBar with a new [value] to update the visual appearance of
  /// the seekBar.
  ///
  /// * [value] determines currently selected value for this seekBar.
  /// * [onChanged] is called while the user is selecting a new value for the
  ///   seekBar.
  /// * [onChangeStart] is called when the user starts to select a new value for
  ///   the seekBar.
  /// * [onChangeEnd] is called when the user is done selecting a new value for
  ///   the seekBar.
  ///
  /// You can override some of the colors with the [playedColor] and
  /// [backgroundColor] properties, although more fine-grained control of the
  /// appearance is achieved using a [SeekBarThemeData].
  SeekBar({
    Key key,
    @required this.value,
    this.buffer = Duration.zero,
    @required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = Duration.zero,
    this.max = Duration.zero,
    this.divisions,
    this.label,
    this.playedColor,
    this.bufferedColor,
    this.backgroundColor,
    this.semanticFormatterCallback,
  })  : assert(value != null),
        assert(buffer != null),
        assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(value >= min && value <= max),
        assert(buffer >= min && value <= max),
        assert(divisions == null || divisions > 0),
        super(key: key);

  /// The currently selected value for this seekBar.
  ///
  /// The seekBar's thumb is drawn at a position that corresponds to this value.
  final Duration value;

  /// The currently buffered ranges for this seekBar.
  ///
  /// The seekBars buffer is drawn at the position that corresponds to this value.
  final Duration buffer;

  /// Called during a drag when the user is selecting a new value for the seekBar
  /// by dragging.
  ///
  /// The seekBar passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the seekBar with the new
  /// value.
  ///
  /// If null, the seekBar will be displayed as disabled.
  ///
  /// The callback provided to onChanged should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// SeekBar(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when the user starts
  ///    changing the value.
  ///  * [onChangeEnd] for a callback that is called when the user stops
  ///    changing the value.
  final ValueChanged<Duration> onChanged;

  /// Called when the user starts selecting a new value for the seekBar.
  ///
  /// This callback shouldn't be used to update the seekBar [value] (use
  /// [onChanged] for that), but rather to be notified when the user has started
  /// selecting a new value by starting a drag or with a tap.
  ///
  /// The value passed will be the last [value] that the seekBar had before the
  /// change began.
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// SeekBar(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  ///   onChangeStart: (double startValue) {
  ///     print('Started change at $startValue');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeEnd] for a callback that is called when the value change is
  ///    complete.
  final ValueChanged<Duration> onChangeStart;

  /// Called when the user is done selecting a new value for the seekBar.
  ///
  /// This callback shouldn't be used to update the seekBar [value] (use
  /// [onChanged] for that), but rather to know when the user has completed
  /// selecting a new [value] by ending a drag or a click.
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// SeekBar(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  ///   onChangeEnd: (double newValue) {
  ///     print('Ended change on $newValue');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when a value change
  ///    begins.
  final ValueChanged<Duration> onChangeEnd;

  /// The minimum value the user can select.
  ///
  /// Defaults to Duration.zero. Must be less than or equal to [max].
  ///
  /// If the [max] is equal to the [min], then the seekBar is disabled.
  final Duration min;

  /// The maximum value the user can select.
  ///
  /// Defaults to Duration.zero. Must be greater than or equal to [min].
  ///
  /// If the [max] is equal to the [min], then the seekBar is disabled.
  final Duration max;

  /// The number of discrete divisions.
  ///
  /// Typically used with [label] to show the current discrete value.
  ///
  /// If null, the seekBar is continuous.
  final int divisions;

  /// A label to show above the seekBar when the seekBar is active.
  ///
  /// It is used to display the value of a discrete seekBar, and it is displayed
  /// as part of the value indicator shape.
  ///
  /// The label is rendered using the active [ThemeData]'s
  /// [ThemeData.accentTextTheme.body2] text style.
  ///
  /// If null, then the value indicator will not be displayed.
  ///
  /// See also:
  ///
  ///  * [SeekBarComponentShape] for how to create a custom value indicator
  ///    shape.
  final String label;

  /// The color to use for the portion of the seekBar track that is active.
  ///
  /// The "active" side of the seekBar is the side between the thumb and the
  /// minimum value.
  ///
  /// Defaults to [SeekBarTheme.activeTrackColor] of the current [SeekBarTheme].
  ///
  /// Using a [SeekBarTheme] gives much more fine-grained control over the
  /// appearance of various components of the seekBar.
  final Color playedColor;

  final Color bufferedColor;

  /// The color for the inactive portion of the seekBar track.
  ///
  /// The "inactive" side of the seekBar is the side between the thumb and the
  /// maximum value.
  ///
  /// Defaults to the [SeekBarTheme.inactiveTrackColor] of the current
  /// [SeekBarTheme].
  ///
  /// Using a [SeekBarTheme] gives much more fine-grained control over the
  /// appearance of various components of the seekBar.
  final Color backgroundColor;

  /// The callback used to create a semantic value from a seekBar value.
  ///
  /// Defaults to formatting values as a percentage.
  ///
  /// This is used by accessibility frameworks like TalkBack on Android to
  /// inform users what the currently selected value is with more context.
  ///
  /// {@tool sample}
  ///
  /// In the example below, a seekBar for currency values is configured to
  /// announce a value with a currency label.
  ///
  /// ```dart
  /// SeekBar(
  ///   value: _dollars.toDouble(),
  ///   min: 20.0,
  ///   max: 330.0,
  ///   label: '$_dollars dollars',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _dollars = newValue.round();
  ///     });
  ///   },
  ///   semanticFormatterCallback: (double newValue) {
  ///     return '${newValue.round()} dollars';
  ///   }
  ///  )
  /// ```
  /// {@end-tool}
  final SemanticFormatterCallback semanticFormatterCallback;

  @override
  _SeekBarState createState() => _SeekBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('value duration', value.inMilliseconds, unit: 'ms'))
      ..add(IntProperty('min duration', min.inMilliseconds, unit: 'ms'))
      ..add(IntProperty('max duration', max.inMilliseconds, unit: 'ms'))
      ..add(IntProperty('buffer duration ', buffer.inMicroseconds, unit: 'ms'));
  }
}

class _SeekBarState extends State<SeekBar> with TickerProviderStateMixin {
  static const Duration enableAnimationDuration = Duration(milliseconds: 75);
  static const Duration valueIndicatorAnimationDuration =
      Duration(milliseconds: 100);

  // Animation controller that is run when the overlay (a.k.a radial reaction)
  // is shown in response to user interaction.
  AnimationController overlayController;

  // Animation controller that is run when the value indicator is being shown
  // or hidden.
  AnimationController valueIndicatorController;

  // Animation controller that is run when enabling/disabling the seekBar.
  AnimationController enableController;

  // Animation controller that is run when transitioning between one value
  // and the next on a discrete seekBar.
  AnimationController positionController;

  AnimationController bufferController;

  Timer interactionTimer;

  @override
  void initState() {
    super.initState();
    overlayController = AnimationController(
      duration: kRadialReactionDuration,
      vsync: this,
    );
    valueIndicatorController = AnimationController(
      duration: valueIndicatorAnimationDuration,
      vsync: this,
    );
    enableController = AnimationController(
      duration: enableAnimationDuration,
      vsync: this,
    );
    positionController = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );
    bufferController = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );
    enableController.value = widget.onChanged != null ? 1.0 : 0.0;
    positionController.value = _unlerp(widget.value.inMicroseconds.toDouble());
    bufferController.value = _unlerp(widget.buffer.inMicroseconds.toDouble());
  }

  @override
  void dispose() {
    interactionTimer?.cancel();
    overlayController.dispose();
    valueIndicatorController.dispose();
    enableController.dispose();
    positionController.dispose();
    bufferController.dispose();
    super.dispose();
  }

  void _handleChanged(double value) {
    assert(widget.onChanged != null);
    final Duration lerpValue = _lerp(value);
    if (lerpValue != widget.value) {
      widget.onChanged(lerpValue);
    }
  }

  void _handleDragStart(double value) {
    assert(widget.onChangeStart != null);
    widget.onChangeStart(_lerp(value));
  }

  void _handleDragEnd(double value) {
    assert(widget.onChangeEnd != null);
    widget.onChangeEnd(_lerp(value));
  }

  // Returns a number between min and max, proportional to value, which must
  // be between 0.0 and 1.0.
  Duration _lerp(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    final double newValue = value *
            (widget.max.inMicroseconds.toDouble() -
                widget.min.inMicroseconds.toDouble()) +
        widget.min.inMicroseconds.toDouble();

    return Duration(microseconds: newValue.toInt());
  }

  // Returns a number between 0.0 and 1.0, given a value between min and max.
  double _unlerp(double value) {
    assert(value <= widget.max.inMicroseconds.toDouble());
    assert(value >= widget.min.inMicroseconds.toDouble());
    return widget.max > widget.min
        ? (value - widget.min.inMicroseconds.toDouble()) /
            (widget.max.inMicroseconds.toDouble() -
                widget.min.inMicroseconds.toDouble())
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMediaQuery(context));

    SeekBarThemeData seekBarTheme = SeekBarTheme.of(context);

    // If the widget has active or inactive colors specified, then we plug them
    // in to the seekBar theme as best we can. If the developer wants more
    // control than that, then they need to use a SeekBarTheme.
    if (widget.playedColor != null ||
        widget.bufferedColor != null ||
        widget.backgroundColor != null) {
      seekBarTheme = seekBarTheme.copyWith(
        activeTrackColor: widget.playedColor,
        bufferTrackColor: widget.bufferedColor,
        inactiveTrackColor: widget.backgroundColor,
        activeTickMarkColor: widget.backgroundColor,
        inactiveTickMarkColor: widget.playedColor,
        thumbColor: widget.playedColor,
        valueIndicatorColor: widget.playedColor,
        overlayColor: widget.playedColor?.withAlpha(0x29),
      );
    }

    return _SeekBarRenderObjectWidget(
      value: _unlerp(widget.value.inMicroseconds.toDouble()),
      buffer: _unlerp(widget.buffer.inMicroseconds.toDouble()),
      divisions: widget.divisions,
      label: widget.label,
      seekBarTheme: seekBarTheme,
      mediaQueryData: MediaQuery.of(context),
      onChanged: (widget.onChanged != null) && (widget.max > widget.min)
          ? _handleChanged
          : null,
      onChangeStart: widget.onChangeStart != null ? _handleDragStart : null,
      onChangeEnd: widget.onChangeEnd != null ? _handleDragEnd : null,
      state: this,
      semanticFormatterCallback: widget.semanticFormatterCallback,
    );
  }
}

class _SeekBarRenderObjectWidget extends LeafRenderObjectWidget {
  const _SeekBarRenderObjectWidget({
    Key key,
    this.value,
    this.buffer,
    this.divisions,
    this.label,
    this.seekBarTheme,
    this.mediaQueryData,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.state,
    this.semanticFormatterCallback,
  }) : super(key: key);

  final double value;
  final double buffer;
  final int divisions;
  final String label;
  final SeekBarThemeData seekBarTheme;
  final MediaQueryData mediaQueryData;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;
  final SemanticFormatterCallback semanticFormatterCallback;
  final _SeekBarState state;

  @override
  _RenderSeekBar createRenderObject(BuildContext context) {
    return _RenderSeekBar(
      value: value,
      buffer: buffer,
      divisions: divisions,
      label: label,
      seekBarTheme: seekBarTheme,
      theme: Theme.of(context),
      mediaQueryData: mediaQueryData,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      state: state,
      textDirection: Directionality.of(context),
      semanticFormatterCallback: semanticFormatterCallback,
      platform: Theme.of(context).platform,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSeekBar renderObject) {
    renderObject
      ..value = value
      ..buffer = buffer
      ..divisions = divisions
      ..label = label
      ..seekBarTheme = seekBarTheme
      ..theme = Theme.of(context)
      ..mediaQueryData = mediaQueryData
      ..onChanged = onChanged
      ..onChangeStart = onChangeStart
      ..onChangeEnd = onChangeEnd
      ..textDirection = Directionality.of(context)
      ..semanticFormatterCallback = semanticFormatterCallback
      ..platform = Theme.of(context).platform;
    // Ticker provider cannot change since there's a 1:1 relationship between
    // the _SeekBarRenderObjectWidget object and the _SeekBarState object.
  }
}

class _RenderSeekBar extends RenderBox {
  _RenderSeekBar({
    @required double value,
    @required double buffer,
    int divisions,
    String label,
    SeekBarThemeData seekBarTheme,
    ThemeData theme,
    MediaQueryData mediaQueryData,
    TargetPlatform platform,
    ValueChanged<double> onChanged,
    SemanticFormatterCallback semanticFormatterCallback,
    this.onChangeStart,
    this.onChangeEnd,
    @required _SeekBarState state,
    @required TextDirection textDirection,
  })  : assert(value != null && value >= 0.0 && value <= 1.0),
        assert(buffer != null && buffer >= 0.0 && buffer <= 1.0),
        assert(state != null),
        assert(textDirection != null),
        _platform = platform,
        _semanticFormatterCallback = semanticFormatterCallback,
        _label = label,
        _value = value,
        _buffer = buffer,
        _divisions = divisions,
        _seekBarTheme = seekBarTheme,
        _theme = theme,
        _mediaQueryData = mediaQueryData,
        _onChanged = onChanged,
        _state = state,
        _textDirection = textDirection {
    _updateLabelPainter();
    final GestureArenaTeam team = GestureArenaTeam();
    _drag = HorizontalDragGestureRecognizer()
      ..team = team
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _endInteraction;
    _tap = TapGestureRecognizer()
      ..team = team
      ..onTapDown = _handleTapDown
      ..onTapUp = _handleTapUp
      ..onTapCancel = _endInteraction;
    _overlayAnimation = CurvedAnimation(
      parent: _state.overlayController,
      curve: Curves.fastOutSlowIn,
    );
    _valueIndicatorAnimation = CurvedAnimation(
      parent: _state.valueIndicatorController,
      curve: Curves.fastOutSlowIn,
    );
    _enableAnimation = CurvedAnimation(
      parent: _state.enableController,
      curve: Curves.easeInOut,
    );
  }

  static const Duration _positionAnimationDuration = Duration(milliseconds: 75);
  static const Duration _minimumInteractionTime = Duration(milliseconds: 500);

  // This value is the touch target, 48, multiplied by 3.
  static const double _minPreferredTrackWidth = 144.0;

  // Compute the largest width and height needed to paint the seekBar shapes,
  // other than the track shape. It is assumed that these shapes are vertically
  // centered on the track.
  double get _maxSeekBarPartWidth =>
      _seekBarPartSizes.map((Size size) => size.width).reduce(math.max);

  double get _maxSeekBarPartHeight =>
      _seekBarPartSizes.map((Size size) => size.width).reduce(math.max);

  List<Size> get _seekBarPartSizes => <Size>[
        _seekBarTheme.overlayShape.getPreferredSize(isInteractive, isDiscrete),
        _seekBarTheme.thumbShape.getPreferredSize(isInteractive, isDiscrete),
        _seekBarTheme.tickMarkShape.getPreferredSize(
            isEnabled: isInteractive, seekBarTheme: seekBarTheme),
      ];

  double get _minPreferredTrackHeight => _seekBarTheme.trackHeight;

  _SeekBarState _state;
  Animation<double> _overlayAnimation;
  Animation<double> _valueIndicatorAnimation;
  Animation<double> _enableAnimation;
  final TextPainter _labelPainter = TextPainter();
  HorizontalDragGestureRecognizer _drag;
  TapGestureRecognizer _tap;
  bool _active = false;
  double _currentDragValue = 0.0;

  // This rect is used in gesture calculations, where the gesture coordinates
  // are relative to the seekBars origin. Therefore, the offset is passed as
  // (0,0).
  Rect get _trackRect => _seekBarTheme.trackActiveShape.getPreferredRect(
        parentBox: this,
        offset: Offset.zero,
        seekBarTheme: _seekBarTheme,
        isDiscrete: false,
      );

  bool get isInteractive => onChanged != null;

  bool get isDiscrete => divisions != null && divisions > 0;

  double _value;

  double get value => _value;

  set value(double newValue) {
    assert(newValue != null && newValue >= 0.0 && newValue <= 1.0);
    final double convertedValue = isDiscrete ? _discretize(newValue) : newValue;
    if (convertedValue == _value) {
      return;
    }
    _value = convertedValue;
    if (isDiscrete) {
      // Reset the duration to match the distance that we're traveling, so that
      // whatever the distance, we still do it in _positionAnimationDuration,
      // and if we get re-targeted in the middle, it still takes that long to
      // get to the new location.
      final double distance = (_value - _state.positionController.value).abs();
      _state.positionController.duration = distance != 0.0
          ? _positionAnimationDuration * (1.0 / distance)
          : Duration.zero;
      _state.positionController
          .animateTo(convertedValue, curve: Curves.easeInOut);
    } else {
      _state.positionController.value = convertedValue;
    }
    markNeedsSemanticsUpdate();
  }

  double _buffer;

  double get buffer => _buffer;

  set buffer(double newBuffer) {
    assert(newBuffer != null && newBuffer >= 0.0 && newBuffer <= 1.0);
    _state.bufferController.value = newBuffer;
  }

  TargetPlatform _platform;

  TargetPlatform get platform => _platform;

  set platform(TargetPlatform value) {
    if (_platform == value) return;
    _platform = value;
    markNeedsSemanticsUpdate();
  }

  SemanticFormatterCallback _semanticFormatterCallback;

  SemanticFormatterCallback get semanticFormatterCallback =>
      _semanticFormatterCallback;

  set semanticFormatterCallback(SemanticFormatterCallback value) {
    if (_semanticFormatterCallback == value) return;
    _semanticFormatterCallback = value;
    markNeedsSemanticsUpdate();
  }

  int get divisions => _divisions;
  int _divisions;

  set divisions(int value) {
    if (value == _divisions) {
      return;
    }
    _divisions = value;
    markNeedsPaint();
  }

  String get label => _label;
  String _label;

  set label(String value) {
    if (value == _label) {
      return;
    }
    _label = value;
    _updateLabelPainter();
  }

  SeekBarThemeData get seekBarTheme => _seekBarTheme;
  SeekBarThemeData _seekBarTheme;

  set seekBarTheme(SeekBarThemeData value) {
    if (value == _seekBarTheme) {
      return;
    }
    _seekBarTheme = value;
    markNeedsPaint();
  }

  ThemeData get theme => _theme;
  ThemeData _theme;

  set theme(ThemeData value) {
    if (value == _theme) {
      return;
    }
    _theme = value;
    markNeedsPaint();
  }

  MediaQueryData get mediaQueryData => _mediaQueryData;
  MediaQueryData _mediaQueryData;

  set mediaQueryData(MediaQueryData value) {
    if (value == _mediaQueryData) {
      return;
    }
    _mediaQueryData = value;
    // Media query data includes the textScaleFactor, so we need to update the
    // label painter.
    _updateLabelPainter();
  }

  ValueChanged<double> get onChanged => _onChanged;
  ValueChanged<double> _onChanged;

  set onChanged(ValueChanged<double> value) {
    if (value == _onChanged) {
      return;
    }
    final bool wasInteractive = isInteractive;
    _onChanged = value;
    if (wasInteractive != isInteractive) {
      if (isInteractive) {
        _state.enableController.forward();
      } else {
        _state.enableController.reverse();
      }
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  ValueChanged<double> onChangeStart;
  ValueChanged<double> onChangeEnd;

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    assert(value != null);
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    _updateLabelPainter();
  }

  bool get showValueIndicator {
    bool showValueIndicator;
    switch (_seekBarTheme.showValueIndicator) {
      case ShowSeekBarValueIndicator.onlyForDiscrete:
        showValueIndicator = isDiscrete;
        break;
      case ShowSeekBarValueIndicator.onlyForContinuous:
        showValueIndicator = !isDiscrete;
        break;
      case ShowSeekBarValueIndicator.always:
        showValueIndicator = true;
        break;
      case ShowSeekBarValueIndicator.never:
        showValueIndicator = false;
        break;
    }
    return showValueIndicator;
  }

  double get _adjustmentUnit {
    switch (_platform) {
      case TargetPlatform.iOS:
        // Matches iOS implementation of material seekBar.
        return 0.1;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      default:
        // Matches Android implementation of material seekBar.
        return 0.05;
    }
  }

  void _updateLabelPainter() {
    if (label != null) {
      _labelPainter
        ..text = TextSpan(
          style: _seekBarTheme.valueIndicatorTextStyle,
          text: label,
        )
        ..textDirection = textDirection
        ..textScaleFactor = _mediaQueryData.textScaleFactor
        ..layout();
    } else {
      _labelPainter.text = null;
    }
    // Changing the textDirection can result in the layout changing, because the
    // bidi algorithm might line up the glyphs differently which can result in
    // different ligatures, different shapes, etc. So we always markNeedsLayout.
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _overlayAnimation.addListener(markNeedsPaint);
    _valueIndicatorAnimation.addListener(markNeedsPaint);
    _enableAnimation.addListener(markNeedsPaint);
    _state.positionController.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _overlayAnimation.removeListener(markNeedsPaint);
    _valueIndicatorAnimation.removeListener(markNeedsPaint);
    _enableAnimation.removeListener(markNeedsPaint);
    _state.positionController.removeListener(markNeedsPaint);
    super.detach();
  }

  double _getValueFromVisualPosition(double visualPosition) {
    switch (textDirection) {
      case TextDirection.rtl:
        return 1.0 - visualPosition;
      case TextDirection.ltr:
        return visualPosition;
    }
    return null;
  }

  double _getValueFromGlobalPosition(Offset globalPosition) {
    final double visualPosition =
        (globalToLocal(globalPosition).dx - _trackRect.left) / _trackRect.width;
    return _getValueFromVisualPosition(visualPosition);
  }

  double _discretize(double value) {
    double result = value.clamp(0.0, 1.0);
    if (isDiscrete) {
      result = (result * divisions).round() / divisions;
    }
    return result;
  }

  void _startInteraction(Offset globalPosition) {
    if (isInteractive) {
      _active = true;
      // We supply the *current* value as the start location, so that if we have
      // a tap, it consists of a call to onChangeStart with the previous value and
      // a call to onChangeEnd with the new value.
      if (onChangeStart != null) {
        onChangeStart(_discretize(value));
      }
      _currentDragValue = _getValueFromGlobalPosition(globalPosition);
      onChanged(_discretize(_currentDragValue));
      _state.overlayController.forward();
      if (showValueIndicator) {
        _state.valueIndicatorController.forward();
        _state.interactionTimer?.cancel();
        _state.interactionTimer =
            Timer(_minimumInteractionTime * timeDilation, () {
          _state.interactionTimer = null;
          if (!_active &&
              _state.valueIndicatorController.status ==
                  AnimationStatus.completed) {
            _state.valueIndicatorController.reverse();
          }
        });
      }
    }
  }

  void _endInteraction() {
    if (_active && _state.mounted) {
      if (onChangeEnd != null) {
        onChangeEnd(_discretize(_currentDragValue));
      }
      _active = false;
      _currentDragValue = 0.0;
      _state.overlayController.reverse();
      if (showValueIndicator && _state.interactionTimer == null) {
        _state.valueIndicatorController.reverse();
      }
    }
  }

  void _handleDragStart(DragStartDetails details) =>
      _startInteraction(details.globalPosition);

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      final double valueDelta = details.primaryDelta / _trackRect.width;
      switch (textDirection) {
        case TextDirection.rtl:
          _currentDragValue -= valueDelta;
          break;
        case TextDirection.ltr:
          _currentDragValue += valueDelta;
          break;
      }
      onChanged(_discretize(_currentDragValue));
    }
  }

  void _handleDragEnd(DragEndDetails details) => _endInteraction();

  void _handleTapDown(TapDownDetails details) =>
      _startInteraction(details.globalPosition);

  void _handleTapUp(TapUpDetails details) => _endInteraction();

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && isInteractive) {
      // We need to add the drag first so that it has priority.
      _drag.addPointer(event);
      _tap.addPointer(event);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _minPreferredTrackWidth + _maxSeekBarPartWidth;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _minPreferredTrackWidth + _maxSeekBarPartWidth;

  @override
  double computeMinIntrinsicHeight(double width) =>
      max(_minPreferredTrackHeight, _maxSeekBarPartHeight);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      max(_minPreferredTrackHeight, _maxSeekBarPartHeight);

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = Size(
      constraints.hasBoundedWidth
          ? constraints.maxWidth
          : _minPreferredTrackWidth + _maxSeekBarPartWidth,
      constraints.hasBoundedHeight
          ? constraints.maxHeight
          : max(_minPreferredTrackHeight, _maxSeekBarPartHeight),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double value = _state.positionController.value;
    final double buffer = _state.bufferController.value;

    // The visual thumb position is the position of the thumb from 0 to 1 from
    // left to right. In left to right, this is the same as the value, but it is
    // reversed for right to left text.
    double visualThumbPosition;
    switch (textDirection) {
      case TextDirection.ltr:
        visualThumbPosition = value;
        break;
      case TextDirection.rtl:
        visualThumbPosition = 1.0 - value;
        break;
    }

    // The visual buffer positions are the start and the end position of buffer
    // ranges. In left to right, this is the same as the value, but it is
    // reversed for right to left text.
    double visualBufferPosition;
    switch (textDirection) {
      case TextDirection.ltr:
        visualBufferPosition = buffer;
        break;
      case TextDirection.rtl:
        visualBufferPosition = 1.0 - buffer;
        break;
    }

    final Rect trackRect = _seekBarTheme.trackInactiveShape.getPreferredRect(
      parentBox: this,
      offset: offset,
      seekBarTheme: _seekBarTheme,
      isDiscrete: isDiscrete,
    );

    final Offset thumbCenter = Offset(
        trackRect.left + visualThumbPosition * trackRect.width,
        trackRect.center.dy);

    final Offset bufferCenter = Offset(
        trackRect.left + visualBufferPosition * trackRect.width,
        trackRect.center.dy);

    // Inactive side of the track
    _seekBarTheme.trackInactiveShape.paint(
      context,
      offset,
      parentBox: this,
      seekBarTheme: _seekBarTheme,
      enableAnimation: _enableAnimation,
      textDirection: _textDirection,
      thumbCenter: thumbCenter,
      bufferCenter: bufferCenter,
      isDiscrete: isDiscrete,
      isEnabled: isInteractive,
    );

    // Buffers of the track
    _seekBarTheme.trackBufferShape.paint(
      context,
      offset,
      parentBox: this,
      seekBarTheme: _seekBarTheme,
      enableAnimation: _enableAnimation,
      textDirection: _textDirection,
      thumbCenter: thumbCenter,
      bufferCenter: bufferCenter,
      isDiscrete: isDiscrete,
      isEnabled: isInteractive,
    );

    // Active side of the track
    _seekBarTheme.trackActiveShape.paint(
      context,
      offset,
      parentBox: this,
      seekBarTheme: _seekBarTheme,
      enableAnimation: _enableAnimation,
      textDirection: _textDirection,
      thumbCenter: thumbCenter,
      bufferCenter: bufferCenter,
      isDiscrete: isDiscrete,
      isEnabled: isInteractive,
    );

    // TODO(closkmith): Move this to paint after the thumb.
    if (!_overlayAnimation.isDismissed) {
      _seekBarTheme.overlayShape.paint(
        context,
        thumbCenter,
        activationAnimation: _overlayAnimation,
        enableAnimation: _enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: _labelPainter,
        parentBox: this,
        seekBarTheme: _seekBarTheme,
        textDirection: _textDirection,
        value: _value,
      );
    }

    if (isDiscrete) {
      // TODO(clocksmith): Align tick mark centers to ends of track by not subtracting diameter from length.
      final double tickMarkWidth = _seekBarTheme.tickMarkShape
          .getPreferredSize(
            isEnabled: isInteractive,
            seekBarTheme: _seekBarTheme,
          )
          .width;
      final double adjustedTrackWidth = trackRect.width - tickMarkWidth;
      // If the tick marks would be too dense, don't bother painting them.
      if (adjustedTrackWidth / divisions >= 3.0 * tickMarkWidth) {
        final double dy = trackRect.center.dy;
        for (int i = 0; i <= divisions; i++) {
          final double value = i / divisions;
          // The ticks are mapped to be within the track, so the tick mark width
          // must be subtracted from the track width.
          final double dx =
              trackRect.left + value * adjustedTrackWidth + tickMarkWidth / 2;
          final Offset tickMarkOffset = Offset(dx, dy);
          _seekBarTheme.tickMarkShape.paint(
            context,
            tickMarkOffset,
            parentBox: this,
            seekBarTheme: _seekBarTheme,
            enableAnimation: _enableAnimation,
            textDirection: _textDirection,
            thumbCenter: thumbCenter,
            isEnabled: isInteractive,
          );
        }
      }
    }

    if (isInteractive &&
        label != null &&
        !_valueIndicatorAnimation.isDismissed) {
      if (showValueIndicator) {
        _seekBarTheme.valueIndicatorShape.paint(
          context,
          thumbCenter,
          activationAnimation: _valueIndicatorAnimation,
          enableAnimation: _enableAnimation,
          isDiscrete: isDiscrete,
          labelPainter: _labelPainter,
          parentBox: this,
          seekBarTheme: _seekBarTheme,
          textDirection: _textDirection,
          value: _value,
        );
      }
    }

    _seekBarTheme.thumbShape.paint(
      context,
      thumbCenter,
      activationAnimation: _valueIndicatorAnimation,
      enableAnimation: _enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: _labelPainter,
      parentBox: this,
      seekBarTheme: _seekBarTheme,
      textDirection: _textDirection,
      value: _value,
    );
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = isInteractive;
    if (isInteractive) {
      config.textDirection = textDirection;
      config.onIncrease = _increaseAction;
      config.onDecrease = _decreaseAction;
      if (semanticFormatterCallback != null) {
        config.value = semanticFormatterCallback(_state._lerp(value));
        config.increasedValue = semanticFormatterCallback(
            _state._lerp((value + _semanticActionUnit).clamp(0.0, 1.0)));
        config.decreasedValue = semanticFormatterCallback(
            _state._lerp((value - _semanticActionUnit).clamp(0.0, 1.0)));
      } else {
        config.value = '${(value * 100).round()}%';
        config.increasedValue =
            '${((value + _semanticActionUnit).clamp(0.0, 1.0) * 100).round()}%';
        config.decreasedValue =
            '${((value - _semanticActionUnit).clamp(0.0, 1.0) * 100).round()}%';
      }
    }
  }

  double get _semanticActionUnit =>
      divisions != null ? 1.0 / divisions : _adjustmentUnit;

  void _increaseAction() {
    if (isInteractive) {
      onChanged((value + _semanticActionUnit).clamp(0.0, 1.0));
    }
  }

  void _decreaseAction() {
    if (isInteractive) {
      onChanged((value - _semanticActionUnit).clamp(0.0, 1.0));
    }
  }
}
