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
  Future<List<XFile>> loadFile({List<String> acceptedTypes}) {
    String inputString = '';
    for (String element in acceptedTypes) {
      if (inputString.isNotEmpty) {
        inputString += ',';
      }
      inputString += element;
    }
    
    // Create a file input element
    html.FileUploadInputElement element = html.FileUploadInputElement();
    if (inputString.isNotEmpty) {
      element.accept = inputString;
    }
    element.multiple = true;

    // Add the file input element and click it
    _target.children.clear();
    _target.children.add(element);
    element.click();
    
    Completer<List<XFile>> _completer = Completer<List<XFile>>();
    
    // Get the returned files
    // TODO: Handle errors
    element.onChange.first.then((event) {
      // TODO: Multiple files
      List<html.File> files = element.files;
      List<XFile> returnFiles = List<XFile>();

      for (html.File file in files) {
        String url = html.Url.createObjectUrl(file);
        String name = file.name;
        int length = file.size;

        returnFiles.add(new XFile(url, name: name, length: length));
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
    html.Blob blob;
    if(type.isEmpty) {
      blob = html.Blob([data]);
    } else {
      blob = html.Blob([data], type);
    }
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
