import 'package:flutter/material.dart';

/// Customization of the Mouse Pointer
class Cursor {
  const Cursor(this._type) :
  _macOSCursor = null,
  _webCursorType = null;

  /// Fallback to a arrow cursor.
  const Cursor.fallback()
      : _type = CursorType.arrow,
        _macOSCursor = MacOSCursor.arrow,
        _webCursorType = WebCursor.arrow;

  /// Custom cursor with an option to specify MacOS and Web cursors explicitly.
  const Cursor.custom({
    @required CursorType type,
    MacOSCursor MacOSCursor,
    WebCursor webCursorType,
  })  : assert(type != null),
        _type = type,
        _macOSCursor = MacOSCursor,
        _webCursorType = webCursorType;

  final CursorType _type;
  final MacOSCursor _macOSCursor;
  final WebCursor _webCursorType;

  /// Cursor Type
  CursorType get value => _type;

  /// [MacOS] Cursor Type derived from [CursorType]
  /// or set explicitly
  MacOSCursor get macOSCursor {
    if (_macOSCursor != null) {
      return _macOSCursor;
    }
    switch (_type) {
      case CursorType.arrow:
        return MacOSCursor.arrow;
      case CursorType.cross:
        return MacOSCursor.crossHair;
      case CursorType.hand:
        return MacOSCursor.openHand;
      case CursorType.resizeLeft:
        return MacOSCursor.resizeLeft;
      case CursorType.resizeRight:
        return MacOSCursor.resizeRight;
      case CursorType.resizeDown:
        return MacOSCursor.resizeDown;
      case CursorType.resizeUp:
        return MacOSCursor.resizeUp;
      case CursorType.resizeLeftRight:
        return MacOSCursor.resizeLeftRight;
      case CursorType.resizeUpDown:
        return MacOSCursor.resizeUpDown;
    }

    return MacOSCursor.arrow;
  }

  /// [Web] Cursor Type derived from [CursorType]
  /// or set explicitly
  WebCursor get webCursor {
    if (_webCursorType != null) {
      return _webCursorType;
    }

    switch (_type) {
      case CursorType.arrow:
        return WebCursor.arrow;
      case CursorType.cross:
        return WebCursor.crossHair;
      case CursorType.hand:
        return WebCursor.grab;
      case CursorType.resizeLeft:
        return WebCursor.eResize;
      case CursorType.resizeRight:
        return WebCursor.wResize;
      case CursorType.resizeDown:
        return WebCursor.nResize;
      case CursorType.resizeUp:
        return WebCursor.sResize;
      case CursorType.resizeLeftRight:
        return WebCursor.ewResize;
      case CursorType.resizeUpDown:
        return WebCursor.nsResize;
    }

    return WebCursor.arrow;
  }
}

/// Generic [Cursor] type that is shared across all platforms.
enum CursorType {
  arrow,
  cross,
  hand,
  resizeLeft,
  resizeRight,
  resizeDown,
  resizeUp,
  resizeLeftRight,
  resizeUpDown,
}

/// [MacOS] platform cursor
enum MacOSCursor {
  arrow,
  beamVertical,
  crossHair,
  closedHand,
  openHand,
  pointingHand,
  resizeLeft,
  resizeRight,
  resizeDown,
  resizeUp,
  resizeLeftRight,
  resizeUpDown,
  beamHorizontial,
  disappearingItem,
  notAllowed,
  dragLink,
  dragCopy,
  contextMenu,
}

/// [Web] platform cursor
class WebCursor {
  /// [Web] platform cursor
  const WebCursor(String type) : this.type = type;

  /// Current Cursor Type
  final String type;

  static const WebCursor alias = WebCursor("alias");
  static const WebCursor allScroll = WebCursor("all-scroll");
  static const WebCursor auto = WebCursor("auto");
  static const WebCursor cell = WebCursor("cell");
  static const WebCursor contextMenu = WebCursor("context-menu");
  static const WebCursor colResize = WebCursor("col-resize");
  static const WebCursor copy = WebCursor("copy");
  static const WebCursor crossHair = WebCursor("crosshair");
  static const WebCursor arrow = WebCursor("default");
  static const WebCursor eResize = WebCursor("e-resize");
  static const WebCursor ewResize = WebCursor("ew-resize");
  static const WebCursor grab = WebCursor("grab");
  static const WebCursor grabbing = WebCursor("grabbing");
  static const WebCursor help = WebCursor("help");
  static const WebCursor move = WebCursor("move");
  static const WebCursor nResize = WebCursor("n-resize");
  static const WebCursor neResize = WebCursor("ne-resize");
  static const WebCursor neswResize = WebCursor("nesw-resize");
  static const WebCursor nsResize = WebCursor("ns-resize");
  static const WebCursor nwResize = WebCursor("nw-resize");
  static const WebCursor nwseResize = WebCursor("nwse-resize");
  static const WebCursor noDrop = WebCursor("no-drop");
  static const WebCursor none = WebCursor("none");
  static const WebCursor notAllowed = WebCursor("not-allowed");
  static const WebCursor pointer = WebCursor("pointer");
  static const WebCursor progress = WebCursor("progress");
  static const WebCursor rowResize = WebCursor("row-resize");
  static const WebCursor sResize = WebCursor("s-resize");
  static const WebCursor seResize = WebCursor("se-resize");
  static const WebCursor swResize = WebCursor("sw-resize");
  static const WebCursor text = WebCursor("text");
  // static const WebCursor url = WebCursor("url");
  static const WebCursor wResize = WebCursor("w-resize");
  static const WebCursor wait = WebCursor("wait");
  static const WebCursor zoomIn = WebCursor("zoom-in");
  static const WebCursor zoomOut = WebCursor("zoom-out");
}
