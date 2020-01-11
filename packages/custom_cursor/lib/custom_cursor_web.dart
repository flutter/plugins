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
    html.document.body.style.cursor = Cursor.getWebCursor(value);
    return Future.value(true);
  }

  @override
  Future<bool> setWebCursor(WebCursor web) {
    html.document.body.style.cursor = web.value;
    return Future.value(true);
  }
}
