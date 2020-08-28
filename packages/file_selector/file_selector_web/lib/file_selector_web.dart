import 'dart:async';
import 'dart:html';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_platform_interface/src/web_helpers/web_helpers.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

final String _kFileSelectorInputsDomId = '__file_selector_web_file_input';

/// The web implementation of [FileSelectorPlatform].
///
/// This class implements the `package:file_selector` functionality for the web.
class FileSelectorPlugin extends FileSelectorPlatform {
  Element _target;
  final FileSelectorPluginTestOverrides _overrides;

  bool get _hasTestOverrides => _overrides != null;

  /// Open file dialog for loading files and return a XFile
  @override
  Future<XFile> loadFile({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String confirmButtonText,
  }) async {
    return (await _loadFileHelper(false, acceptedTypeGroups)).first;
  }

  /// Open file dialog for loading files and return a XFile
  @override
  Future<List<XFile>> loadFiles({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String confirmButtonText,
  }) async {
    return _loadFileHelper(true, acceptedTypeGroups);
  }

  @override
  Future<String> getSavePath({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String suggestedName,
    String confirmButtonText,
  }) async =>
      null;

  /// Load Helper
  Future<List<XFile>> _loadFileHelper(
      bool multiple, List<XTypeGroup> acceptedTypes) {
    final acceptedTypeString = _getStringFromFilterGroup(acceptedTypes);

    final FileUploadInputElement element =
        createFileInputElement(acceptedTypeString, multiple);

    _target.children.clear();
    addElementToContainerAndClick(_target, element);

    return getFilesWhenReady(element);
  }

  /// Default constructor, initializes _target to a DOM element that we can use
  /// to host HTML elements.
  /// overrides parameter allows for testing to override functions
  FileSelectorPlugin({
    @visibleForTesting FileSelectorPluginTestOverrides overrides,
  }) : _overrides = overrides {
    _target = ensureInitialized(_kFileSelectorInputsDomId);
  }

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith(Registrar registrar) {
    FileSelectorPlatform.instance = FileSelectorPlugin();
  }

  void _verifyXTypeGroup(XTypeGroup group) {
    if (group.extensions == null &&
        group.mimeTypes == null &&
        group.webWildCards == null) {
      StateError(
          "This XTypeGroup does not have types supported by the web implementation of loadFile.");
    }
  }

  /// Convert list of XTypeGroups to a comma-separated string
  String _getStringFromFilterGroup(List<XTypeGroup> acceptedTypes) {
    List<String> allTypes = List();
    for (XTypeGroup group in acceptedTypes ?? []) {
      _verifyXTypeGroup(group);

      for (String mimeType in group.mimeTypes ?? []) {
        allTypes.add(mimeType);
      }
      for (String extension in group.extensions ?? []) {
        String ext = extension;
        if (ext.isNotEmpty && ext[0] != '.') {
          ext = '.' + ext;
        }

        allTypes.add(ext);
      }
      for (String webWildCard in group.webWildCards ?? []) {
        allTypes.add(webWildCard);
      }
    }
    return allTypes?.where((e) => e.isNotEmpty)?.join(',') ?? '';
  }

  /// Creates a file input element with only the accept attribute
  @visibleForTesting
  FileUploadInputElement createFileInputElement(
      String accepted, bool multiple) {
    if (_hasTestOverrides && _overrides.createFileInputElement != null) {
      return _overrides.createFileInputElement(accepted, multiple);
    }

    final FileUploadInputElement element = FileUploadInputElement();
    if (accepted.isNotEmpty) {
      element.accept = accepted;
    }
    element.multiple = multiple;

    return element;
  }

  List<XFile> _getXFilesFromFiles(List<File> files) {
    List<XFile> xFiles = List<XFile>();

    final timeZoneOffset = DateTime.now().timeZoneOffset;

    for (File file in files) {
      String url = Url.createObjectUrl(file);
      String name = file.name;
      int length = file.size;
      DateTime modified = file.lastModifiedDate.add(timeZoneOffset);

      xFiles
          .add(XFile(url, name: name, lastModified: modified, length: length));
    }

    return xFiles;
  }

  /// Getter for retrieving files from an input element
  @visibleForTesting
  List<File> getFilesFromInputElement(InputElement element) {
    if (_hasTestOverrides && _overrides.getFilesFromInputElement != null) {
      return _overrides.getFilesFromInputElement(element);
    }

    return element?.files ?? [];
  }

  /// Listen for file input element to change and retrieve files when
  /// this happens.
  @visibleForTesting
  Future<List<XFile>> getFilesWhenReady(InputElement element) {
    if (_hasTestOverrides && _overrides.getFilesWhenReady != null) {
      return _overrides.getFilesWhenReady(element);
    }

    final Completer<List<XFile>> _completer = Completer();

    // Listens for element change
    element.onChange.first.then((event) {
      // File type from dart:html class
      final List<File> files = getFilesFromInputElement(element);

      // Create XFile from dart:html Files
      final xFiles = _getXFilesFromFiles(files);

      _completer.complete(xFiles);
    });

    element.onError.first.then((event) {
      if (!_completer.isCompleted) {
        _completer.completeError(event);
      }
    });

    return _completer.future;
  }
}

/// Overrides some functions to allow testing
@visibleForTesting
class FileSelectorPluginTestOverrides {
  /// For overriding the creation of the file input element.
  Element Function(String accepted, bool multiple) createFileInputElement;

  /// For overriding retrieving a file from the input element.
  List<File> Function(InputElement input) getFilesFromInputElement;

  /// For overriding waiting for the files to be ready. Useful for testing so we do not hang here.
  Future<List<XFile>> Function(InputElement input) getFilesWhenReady;

  /// Constructor for test override class
  FileSelectorPluginTestOverrides(
      {this.createFileInputElement,
      this.getFilesFromInputElement,
      this.getFilesWhenReady});
}
