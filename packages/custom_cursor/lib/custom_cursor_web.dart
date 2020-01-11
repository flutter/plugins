import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'src/cursor_type.dart';
import 'src/platform_interface.dart';

/// The web implementation of [CustomCursorPlatform].
///
/// This class implements the `package:url_launcher` functionality for the web.
class CustomCursorPlugin extends CustomCursorPlatform {
  /// Registers this class as the default instance of [CustomCursorPlatform].
  static void registerWith(Registrar registrar) {
    CustomCursorPlatform.instance = CustomCursorPlugin();
  }

  @override
  Future<bool> resetCursor() {
    String _cursor = WebCursor.arrow;
    html.document.body.style.cursor = _cursor;
    return Future.value(true);
  }

  @override
  Future<bool> hideCursor() {
    String _cursor = WebCursor.none;
    html.document.body.style.cursor = _cursor;
    return Future.value(true);
  }

  @override
  Future<bool> showCursor() {
    String _cursor = WebCursor.arrow;
    html.document.body.style.cursor = _cursor;
    return Future.value(true);
  }

  @override
  Future<bool> setCursor(CursorType value) {
    html.document.body.style.cursor = _getCursor(value);
    return Future.value(true);
  }

  @override
  Future<bool> setWebCursor(WebCursor web) {
    html.document.body.style.cursor = web.value;
    return Future.value(true);
  }
}

String _getCursor(CursorType cursor) {
  final _cursor = _getWebCursor(cursor);
  return _cursor;
}

String _getWebCursor(CursorType cursor) {
  switch (cursor) {
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
