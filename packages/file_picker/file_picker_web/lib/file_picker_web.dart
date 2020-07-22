import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

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

  /// Load file from user's computer and return it as an XFile
  /// TODO: multiple files
  Future<XFile> loadFile() {
    // Create a file input element
    html.FileUploadInputElement element = html.FileUploadInputElement();
    element.accept = 'text/plain'; // TODO: accept different types
    element.multiple = true;

    // Add the file input element and click it
    _target.children.clear();
    _target.children.add(element);
    element.click();
    
    Completer<XFile> _completer = Completer<XFile>();
    
    // Get the returned files
    // TODO: Handle errors
    element.onChange.first.then((event) {
      // TODO: Multiple files
      html.File files = element.files.first;
      String url = html.Url.createObjectUrl(files);
      String name = files.name;
      int length = files.size;
      
      XFile loadedFile = XFile(url, name: name, length: length);
      
      _completer.complete(loadedFile);
    });
    
    return _completer.future;
  }

  /// Web implementation of saveFile()
  @override
  void saveFile(Uint8List data, {String suggestedName = ''}) async {
    // Create blob from data
    // TODO: Handle different types
    html.Blob blob = html.Blob([data], 'text/plain');
    String url = html.Url.createObjectUrl(blob);

    // Create an <a> tag with the appropriate download attributes and click it
    html.AnchorElement element = html.AnchorElement(
      href: url,
    );
    element.download = suggestedName;
    _target.children.clear();
    _target.children.add(element);
    element.click();
  }

  /// "Hello World" function for testing
  @override
  Future<String> getMessage() {
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
