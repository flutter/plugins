import 'dart:async';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The web implementation of [FilePickerPlatform].
///
/// This class implements the `package:file_picker` functionality for the web.
class FilePickerPlugin extends FilePickerPlatform {
  /// Registers this class as the default instance of [FilePickerPlatform].
  static void registerWith(Registrar registrar) {
    FilePickerPlatform.instance = FilePickerPlugin();
  }


  @override
  Future<String> getMessage() {
    return Future<String>.value("Hello from the web implementation of file_picker!");
  }
}
