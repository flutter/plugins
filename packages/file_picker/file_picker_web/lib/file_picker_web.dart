import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

final String _kFilePickerInputsDomId = '__file_picker_web-file-input';

/// The web implementation of [FilePickerPlatform].
///
/// This class implements the `package:file_picker` functionality for the web.
class FilePickerPlugin extends FilePickerPlatform {
  Element _target;

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
  Future<List<XFile>> loadFile({List<String> acceptedTypes}) {
    String acceptedTypeString = acceptedTypes.where((e) => e.isNotEmpty).join(',');
    
    // Create a file input element
    final FileUploadInputElement element = FileUploadInputElement();
    if (acceptedTypeString.isNotEmpty) {
      element.accept = acceptedTypeString;
    }
    element.multiple = true;

    // Add the file input element and click it
    _target.children.clear();
    _target.children.add(element);
    element.click();
    
    final Completer<List<XFile>> _completer = Completer();
    
    // Get the returned files
    // TODO: Handle errors
    element.onChange.first.then((event) {
      // File type from dart:html class
      List<File> files = element.files;
      List<XFile> returnFiles = List<XFile>();

      for (File file in files) {
        String url = Url.createObjectUrl(file);
        String name = file.name;
        int length = file.size;

        returnFiles.add(XFile(url, name: name, length: length));
      }

      
      _completer.complete(returnFiles);
    });
    
    return _completer.future;
  }

  /// Web implementation of saveFile()
  @override
  void saveFile(Uint8List data, {String type = '', String suggestedName = ''}) async {
    // Create blob from data
    // TODO: Handle different types

    final Blob blob = type.isEmpty ? Blob([data]) : Blob([data]);

    String url = Url.createObjectUrl(blob);

    // Create an <a> tag with the appropriate download attributes and click it
    final AnchorElement element = AnchorElement(
      href: url,
    );
    element.download = suggestedName;
    _target.children.clear();
    _target.children.add(element);
    element.click();
  }

  /// Initializes a DOM container where we can host input elements.
  Element _ensureInitialized(String id) {
    var target = querySelector('#${id}');
    if (target == null) {
      final Element targetElement =
      Element.tag('flt-file-picker-inputs')..id = id;

      querySelector('body').children.add(targetElement);
      target = targetElement;
    }
    return target;
  }
}
