import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

final String _kFilePickerInputsDomId = '__file_picker_web-file-input';

/// The web implementation of [FilePickerPlatform].
///
/// This class implements the `package:file_picker` functionality for the web.
class FilePickerPlugin extends FilePickerPlatform {
  Element _target;
  final FilePickerPluginTestOverrides _overrides;
  bool get _hasTestOverrides => _overrides != null;

  /// Default constructor, initializes _target to a DOM element that we can use 
  /// to host HTML elements.
  /// overrides parameter allows for testing to override functions
  FilePickerPlugin({
    @visibleForTesting FilePickerPluginTestOverrides overrides,
  }) : _overrides = overrides {
    _target = _ensureInitialized(_kFilePickerInputsDomId);
  }

  /// Registers this class as the default instance of [FilePickerPlatform].
  static void registerWith(Registrar registrar) {
    FilePickerPlatform.instance = FilePickerPlugin();
  }
  
  /// Convert list of filter groups to a comma-separated string
  String _getStringFromFilterGroup (List<FileTypeFilterGroup> acceptedTypes) {
    List<String> allExtensions = List();
    for (FileTypeFilterGroup group in acceptedTypes ?? []) {
      allExtensions += group.fileExtensions;
    }
    return allExtensions?.where((e) => e.isNotEmpty)?.join(',') ?? '';
  }

  /// Creates a file input element with only the accept attribute
  @visibleForTesting
  FileUploadInputElement createFileInputElement(String accepted) {
    if (_hasTestOverrides) {
      return _overrides.createFileInputElement(accepted);
    }
    
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

  List<XFile> _getXFilesFromFiles (List<File> files) {
    List<XFile> xFiles = List<XFile>();

    for (File file in files) {
      String url = Url.createObjectUrl(file);
      String name = file.name;
      int length = file.size;

      xFiles.add(XFile(url, name: name, length: length));
    }

    return xFiles;
  }

  /// Getter for retrieving files from an input element
  @visibleForTesting
  List<File> getFilesFromInputElement(InputElement element) {
    if(_hasTestOverrides) {
      return _overrides.getFilesFromInputElement(element);
    }

    return element?.files ?? [];
  }

  /// Listen for file input element to change and retrieve files when
  /// this happens.
  Future<List<XFile>> _getFilesWhenReady(InputElement element) {
    final Completer<List<XFile>> _completer = Completer();

    // Listens for element change
    element.onChange.first.then((event) {
      // File type from dart:html class
      List<File> files = getFilesFromInputElement(element);
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
    final  acceptedTypeString = _getStringFromFilterGroup(acceptedTypes);

    final FileUploadInputElement element = createFileInputElement(acceptedTypeString);

    _addElementToDomAndClick(element);

    return _getFilesWhenReady(element);
  }

  /// Create anchor element with download attribute
  @visibleForTesting
  AnchorElement createAnchorElement(String href, String suggestedName) {
    final AnchorElement element = AnchorElement(href: href);
    element.download = suggestedName;
    return element;
  }

  /// Create blob with specified data of indicated type
  @visibleForTesting
  Blob createBlob(Uint8List data, String type) {
    return type.isEmpty ? Blob([data]) : Blob([data], type);
  }

  /// Web implementation of saveFile()
  @override
  void saveFile(Uint8List data, {String type = '', String suggestedName = ''}) async {
    // Create blob from data
    final blob = createBlob(data, type);
    String url = Url.createObjectUrl(blob);

    // Create an <a> tag with the appropriate download attributes and click it
    final AnchorElement element = createAnchorElement(url, suggestedName);

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
  /// For overriding the creation of the file input element.
  Element Function(String accepted) createFileInputElement;

  /// For overriding retrieving a file from the input element.
  List<File> Function(InputElement input) getFilesFromInputElement;
}