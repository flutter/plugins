abstract class Cursor {
  String get value;
  CursorType get type;

  String get macOSCursor => getMacOSCursor(type);

  String get webCursor => getWebCursor(type);

  static String getMacOSCursor(CursorType type) {
    switch (type) {
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
      default:
    }
    return MacOSCursor.arrow;
  }

  static String getWebCursor(CursorType type) {
    switch (type) {
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
      default:
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
  custom,
}

/// [MacOS] platform cursor
class MacOSCursor extends Cursor {
  MacOSCursor.custom(String value)
      : this._value = value,
        this._type = CursorType.custom;

  MacOSCursor(String value, CursorType type)
      : this._value = value,
        _type = type;

  @override
  String get value => _value;
  final String _value;

  @override
  CursorType get type => _type;
  final CursorType _type;

  static String arrow = 'arrow';
  static String beamVertical = 'beam-vertical';
  static String crossHair = 'cross-hair';
  static String closedHand = 'closed-hand';
  static String openHand = 'open-hand';
  static String pointingHand = 'pointing-hand';
  static String resizeLeft = 'resize-left';
  static String resizeRight = 'resize-right';
  static String resizeDown = 'resize-down';
  static String resizeUp = 'resize-up';
  static String resizeLeftRight = 'resize-left-right';
  static String resizeUpDown = 'resize-up-down';
  static String beamHorizontial = 'beam-horizontial';
  static String disappearingItem = 'disappearing-item';
  static String notAllowed = 'not-allowed';
  static String dragLink = 'drag-link';
  static String dragCopy = 'drag-copy';
  static String contextMenu = 'context-menu';

  static List<String> get values => [
        'arrow',
        'beam-vertical',
        'cross-hair',
        'closed-hand',
        'open-hand',
        'pointing-hand',
        'resize-left',
        'resize-right',
        'resize-down',
        'resize-up',
        'resize-left-right',
        'resize-up-down',
        'beam-horizontial',
        'disappearing-item',
        'not-allowed',
        'drag-link',
        'drag-copy',
        'context-menu',
      ];
}

/// [Web] platform cursor
class WebCursor extends Cursor {
  WebCursor.custom(String value)
      : this._value = value,
        this._type = CursorType.custom;

  WebCursor(String value, CursorType type)
      : this._value = value,
        this._type = type;

  @override
  String get value => _value;
  final String _value;

  @override
  CursorType get type => _type;
  final CursorType _type;

  static String alias = "alias";
  static String allScroll = "all-scroll";
  static String auto = "auto";
  static String cell = "cell";
  static String contextMenu = "context-menu";
  static String colResize = "col-resize";
  static String copy = "copy";
  static String crossHair = "crosshair";
  static String arrow = "default";
  static String eResize = "e-resize";
  static String ewResize = "ew-resize";
  static String grab = "grab";
  static String grabbing = "grabbing";
  static String help = "help";
  static String move = "move";
  static String nResize = "n-resize";
  static String neResize = "ne-resize";
  static String neswResize = "nesw-resize";
  static String nsResize = "ns-resize";
  static String nwResize = "nw-resize";
  static String nwseResize = "nwse-resize";
  static String noDrop = "no-drop";
  static String none = "none";
  static String notAllowed = "not-allowed";
  static String pointer = "pointer";
  static String progress = "progress";
  static String rowResize = "row-resize";
  static String sResize = "s-resize";
  static String seResize = "se-resize";
  static String swResize = "sw-resize";
  static String text = "text";
  // static String  url = "url" ;
  static String wResize = "w-resize";
  static String wait = "wait";
  static String zoomIn = "zoom-in";
  static String zoomOut = "zoom-out";

  static List<String> get values => [
        'all-scroll',
        'auto',
        'cell',
        'context-menu',
        'col-resize',
        'copy',
        'crosshair',
        'default',
        'e-resize',
        'ew-resize',
        'grab',
        'grabbing',
        'help',
        'move',
        'n-resize',
        'ne-resize',
        'nesw-resize',
        'ns-resize',
        'nw-resize',
        'nwse-resize',
        'no-drop',
        'none',
        'not-allowed',
        'pointer',
        'progress',
        'row-resize',
        's-resize',
        'se-resize',
        'sw-resize',
        'text',
        'w-resize',
        'wait',
        'zoom-in',
        'zoom-out',
      ];
}
