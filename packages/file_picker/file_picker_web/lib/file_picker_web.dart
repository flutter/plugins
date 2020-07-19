import 'dart:async';
import 'dart:html' as html;

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

final String _kFilePickerInputsDomId = '__file_picker_web-file-input';

/// The web implementation of [FilePickerPlatform].
///
/// This class implements the `package:file_picker` functionality for the web.
class FilePickerPlugin extends FilePickerPlatform {
  html.Element _target;

  /// Default constructor, initializes _target to a DOM element
  /// that we can use to host HTML elements
  FilePickerPlugin() {
    _target = _ensureInitialized(_kFilePickerInputsDomId);
  }

  /// Registers this class as the default instance of [FilePickerPlatform].
  static void registerWith(Registrar registrar) {
    FilePickerPlatform.instance = FilePickerPlugin();
  }

  /// Test <a> download attribute.
  void _downloadTest() {
    html.Blob blob = html.Blob(["Hello World from blob!"], 'text/plain');

    String url = html.Url.createObjectUrl(blob);

    html.AnchorElement element = html.AnchorElement(
      href: url,
    );
    element.download = '';

    _target.children.clear();
    _target.children.add(element);
    element.click();
  }

  /// Web implementation of saveFile()
  /// TODO: This should take input PickedFile or similar, not string
  @override
  Future<void> saveFile(String file_contents) {

  }

  @override
  Future<String> getMessage() {
    _downloadTest();
    return Future<String>.value("Hello from the web implementation of file_picker!");
  }

  /// Initializes a DOM container where we can host input elements.
  html.Element _ensureInitialized(String id) {
    var target = html.querySelector('#${id}');
    if (target == null) {
      final html.Element targetElement =
      html.Element.tag('flt-image-picker-inputs')..id = id;

      html.querySelector('body').children.add(targetElement);
      target = targetElement;
    }
    return target;
  }
}
