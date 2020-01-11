import 'dart:async';

export 'src/cursor_type.dart';

import 'src/cursor_type.dart';
import 'src/platform_interface.dart';

class CustomCursorPlugin extends CustomCursorPlatform {
  @override
  Future<bool> setWebCursor(WebCursor value) {
    return CustomCursorPlatform.instance.setWebCursor(value);
  }

  @override
  Future<bool> resetCursor() {
    return CustomCursorPlatform.instance.resetCursor();
  }

  @override
  Future<bool> setCursor(CursorType value) {
    return CustomCursorPlatform.instance.setCursor(value);
  }

  @override
  Future<bool> setMacOSCursor(MacOSCursor value) {
    return CustomCursorPlatform.instance.setMacOSCursor(value);
  }

  @override
  Future<bool> showCursor() {
    return CustomCursorPlatform.instance.showCursor();
  }

  @override
  Future<bool> hideCursor() {
    return CustomCursorPlatform.instance.hideCursor();
  }
}
