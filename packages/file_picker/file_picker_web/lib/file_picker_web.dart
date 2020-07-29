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

  FileUploadInputElement _createFileInputElement(String accepted) {
    final FileUploadInputElement element = FileUploadInputElement();
    if (accepted.isNotEmpty) {
      element.accept = accepted;
    }
    element.multiple = true;

    return element;
  }

  void _addElementToDomAndClick(Element element) {
    // Add the file input element and click it
    // All previous elements will be removed before adding the new one
    _target.children.clear();
    _target.children.add(element);
    element.click();
  }

  Future<List<XFile>> _getFileFromInputElement(InputElement element) {
    // Listens for element change
    element.onChange.first.then((event) {
      // File type from dart:html class
      List<File> files = element.files;
      List<XFile> returnFiles = List<XFile>();

      // Create XFiles from dart:html Files
      for (File file in files) {
        String url = Url.createObjectUrl(file);
        String name = file.name;
        int length = file.size;

        returnFiles.add(XFile(url, name: name, length: length));
      }

      _completer.complete(returnFiles);
    });

    element.onError.first.then((event) {
      if (!_completer.isCompleted) {
        _completer.completeError(event);
      }
    });

    return _completer.future;
  }

  /// Load file from user's computer and return it as an XFile
  @override
  Future<List<XFile>> loadFile({List<FileTypeFilterGroup> acceptedTypes}) {
    List<String> allExtensions = List();
    for (FileTypeFilterGroup group in acceptedTypes ?? []) {
      allExtensions += group.fileExtensions;
    }
    String acceptedTypeString = allExtensions?.where((e) => e.isNotEmpty)?.join(',') ?? '';

    final FileUploadInputElement element = _createFileInputElement(acceptedTypeString);

    _addElementToDomAndClick(element);
    
    final Completer<List<XFile>> _completer = Completer();
    
    return _getFileFromInputElement(element);
  }

  AnchorElement _createAnchorElement(String href, String suggestedName) {
    final AnchorElement element = AnchorElement(href: url);
    element.download = suggestedName;
    return element;
  }

  /// Web implementation of saveFile()
  @override
  void saveFile(Uint8List data, {String type = '', String suggestedName = ''}) async {
    // Create blob from data
    // TODO: Handle different types

    final Blob blob = type.isEmpty ? Blob([data]) : Blob([data], type);

    String url = Url.createObjectUrl(blob);

    // Create an <a> tag with the appropriate download attributes and click it
    final AnchorElement element = _createAnchorElement(href: url, suggestedName: suggestedName);

    _addElementToDomAndClick(element);
  }

  /// Initializes a DOM container where we can host elements.
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

/// Overrides some functions to allow testing
@visibleForTesting
class FilePickerPluginTestOverrides {

}