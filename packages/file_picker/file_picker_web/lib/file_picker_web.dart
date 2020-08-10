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
  FileUploadInputElement createFileInputElement(String accepted, bool multiple) {
    if (_hasTestOverrides) {
      return _overrides.createFileInputElement(accepted);
    }
    
    final FileUploadInputElement element = FileUploadInputElement();
    if (accepted.isNotEmpty) {
      element.accept = accepted;
    }
    element.multiple = multiple;

    return element;
  }

  void _addElementToDomAndClick(Element element) {
    // Add the file input element and click it
    // All previous elements will be removed before adding the new one
    _target.children.clear();
    _target.children.add(element);
    element.click();
  }

  List<XPath> _getXPathsFromFiles (List<File> files) {
    List<XPath> xPaths = List<XPath>();

    for (File file in files) {
      String url = Url.createObjectUrl(file);
      String name = file.name;
      int length = file.size;
      int modified = file.lastModified;

      xPaths.add(XPath(url, name: name, modified: modified));
    }

    return xPaths;
  }

  /// Getter for retrieving files from an input element
  @visibleForTesting
  List<File> getFilesFromInputElement(InputElement element) {
    if(_hasTestOverrides) {
      return _overrides.getFilesFromInputElement(element);
    }

    return element?.files ?? [];
  }

  Future<XPath> _getFileWhenReady(InputElement element)  {
    final Completer<XPath> _completer = Completer();
    
    _getFilesWhenReady(element)
      .then((list) {
        _completer.complete(list[0]);
      })
      .catchError((err) {
        _completer.completeError(err);
    });
    
    return _completer.future;
  }
  
  /// Listen for file input element to change and retrieve files when
  /// this happens.
  Future<List<XPath>> _getFilesWhenReady(InputElement element)  {
    final Completer<List<XPath>> _completer = Completer();

    // Listens for element change
    element.onChange.first.then((event) {
      // File type from dart:html class
      final List<File> files = getFilesFromInputElement(element);

      // Create XPath from dart:html Files
      final returnPaths = _getXPathsFromFiles(files);

      _completer.complete(returnPaths);
    });

    element.onError.first.then((event) {
      if (!_completer.isCompleted) {
        _completer.completeError(event);
      }
    });

    return _completer.future;
  }

  /// Create anchor element with download attribute
  @visibleForTesting
  AnchorElement createAnchorElement(String href, String suggestedName) {
    final element = AnchorElement(href: href);
    element.download = suggestedName;
    return element;
  }

  /// Create blob with specified data of indicated type
  @visibleForTesting
  Blob createBlob(Uint8List data, String type) {
    return type.isEmpty ? Blob([data]) : Blob([data], type);
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
  
  /// NEW API
  
  // Load Helper
  Future<List<XPath>> _readPathHelper (bool multiple, List<FileTypeFilterGroup> acceptedTypes) {
    final  acceptedTypeString = _getStringFromFilterGroup(acceptedTypes);

    final FileUploadInputElement element = createFileInputElement(acceptedTypeString, multiple);

    _addElementToDomAndClick(element);

    return _getFilesWhenReady(element);
  }
  
  /// Open file dialog for loading files and return a file path
  @override
  Future<XPath> loadFile({List<FileTypeFilterGroup> acceptedTypes}) {
    Completer<XPath> _completer = Completer();
    _readPathHelper(false, acceptedTypes).then((list) {
        _completer.complete(list.first);
      })
      .catchError((err) {
        _completer.completeError(err);
      });
    
    return _completer.future;
  }

  /// Open file dialog for loading files and return a list of file paths
  @override
  Future<List<XPath>> loadFiles({List<FileTypeFilterGroup> acceptedTypes}) {
    return _readPathHelper(true, acceptedTypes);
  }
  
  @override
  Future<String> getSavePath() => Future.value();

  /// Web implementation of saveFile()
  void saveFile(Uint8List data, {String type = '', String suggestedName = ''}) async {
    // Create blob from data
    final blob = createBlob(data, type);
    String url = Url.createObjectUrl(blob);

    // Create an <a> tag with the appropriate download attributes and click it
    final AnchorElement element = createAnchorElement(url, suggestedName);

    _addElementToDomAndClick(element);
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