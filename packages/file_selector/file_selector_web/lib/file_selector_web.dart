import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

final String _kFileSelectorInputsDomId = '__file_selector_web-file-input';

/// The web implementation of [FileSelectorPlatform].
///
/// This class implements the `package:file_selector` functionality for the web.
class FileSelectorPlugin extends FileSelectorPlatform {
  Element _target;
  final FileSelectorPluginTestOverrides _overrides;
  bool get _hasTestOverrides => _overrides != null;

  /// Default constructor, initializes _target to a DOM element that we can use 
  /// to host HTML elements.
  /// overrides parameter allows for testing to override functions
  FileSelectorPlugin({
    @visibleForTesting FileSelectorPluginTestOverrides overrides,
  }) : _overrides = overrides {
    _target = _ensureInitialized(_kFileSelectorInputsDomId);
  }

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith(Registrar registrar) {
    FileSelectorPlatform.instance = FileSelectorPlugin();
  }
  
  /// Convert list of filter groups to a comma-separated string
  String _getStringFromFilterGroup (List<XTypeGroup> acceptedTypes) {
    List<String> allExtensions = List();
    for (XTypeGroup group in acceptedTypes ?? []) {
      for (XType type in group.fileTypes ?? []) {
        if (type.extension == null) {
          continue;
        }
        allExtensions.add('.' + type.extension);
      }
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

  List<XFile> _getXFilesFromFiles (List<File> files) {
    List<XFile> xFiles = List<XFile>();

    Duration timeZoneOffset = DateTime.now().timeZoneOffset;

    for (File file in files) {
      String url = Url.createObjectUrl(file);
      String name = file.name;
      int length = file.size;
      DateTime modified = file.lastModifiedDate.add(timeZoneOffset);

      xFiles.add(XFile(url, name: name, lastModified: modified));
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

  Future<XFile> _getFileWhenReady(InputElement element)  {
    final Completer<XFile> _completer = Completer();
    
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
  Future<List<XFile>> _getFilesWhenReady(InputElement element)  {
    final Completer<List<XFile>> _completer = Completer();

    // Listens for element change
    element.onChange.first.then((event) {
      // File type from dart:html class
      final List<File> files = getFilesFromInputElement(element);

      // Create XFile from dart:html Files
      final returnPaths = _getXFilesFromFiles(files);

      _completer.complete(returnPaths);
    });

    element.onError.first.then((event) {
      if (!_completer.isCompleted) {
        _completer.completeError(event);
      }
    });

    return _completer.future;
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
  
  /// Load Helper
  Future<List<XFile>> _loadFileHelper (bool multiple, List<XTypeGroup> acceptedTypes) {
    final  acceptedTypeString = _getStringFromFilterGroup(acceptedTypes);

    final FileUploadInputElement element = createFileInputElement(acceptedTypeString, multiple);

    _addElementToDomAndClick(element);

    return _getFilesWhenReady(element);
  }
  
  /// Open file dialog for loading files and return a XFile
  @override
  Future<XFile> loadFile({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
  }) {
    Completer<XFile> _completer = Completer();
    _loadFileHelper(false, acceptedTypeGroups).then((list) {
        _completer.complete(list.first);
      })
      .catchError((err) {
        _completer.completeError(err);
      });
    
    return _completer.future;
  }

  /// Open file dialog for loading files and return a XFile
  @override
  Future<List<XFile>> loadFiles({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
  }) {
    return _loadFileHelper(true, acceptedTypeGroups);
  }
  
  @override
  Future<String> getSavePath({
    String initialDirectory,
    String suggestedName,
  }) => Future.value();
}

/// Overrides some functions to allow testing
@visibleForTesting
class FileSelectorPluginTestOverrides {
  /// For overriding the creation of the file input element.
  Element Function(String accepted) createFileInputElement;

  /// For overriding retrieving a file from the input element.
  List<File> Function(InputElement input) getFilesFromInputElement;
}