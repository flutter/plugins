import 'dart:async';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// The web implementation of [FileSelectorPlatform].
///
/// This class implements the `package:file_selector` functionality for the web.
class FileSelectorWeb extends FileSelectorPlatform {
  final _container;

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith(Registrar registrar) {
    FileSelectorPlatform.instance = FileSelectorWeb();
  }

  /// Default constructor, initializes _container to a DOM element that we can use
  /// to host HTML elements.
  /// overrides parameter allows for testing to override functions
  FileSelectorWeb({@visibleForTesting Element container})
      : _container = container ?? Element.tag('file-selector') {
    querySelector('body').children.add(_container);
  }

  @override
  Future<XFile> openFile({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String confirmButtonText,
  }) async {
    final files = await _openFiles(acceptedTypeGroups: acceptedTypeGroups);
    return files.first;
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String confirmButtonText,
  }) async {
    return _openFiles(acceptedTypeGroups: acceptedTypeGroups, multiple: true);
  }

  @override
  Future<String> getSavePath({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String suggestedName,
    String confirmButtonText,
  }) async =>
      null;

  @override
  Future<String> getDirectoryPath({
    String initialDirectory,
    String confirmButtonText,
  }) async =>
      null;

  Future<List<XFile>> _openFiles({
    List<XTypeGroup> acceptedTypeGroups,
    bool multiple = false,
  }) async {
    final accept = _acceptedTypesToString(acceptedTypeGroups);
    final input = _createInputElement()
      ..accept = accept
      ..multiple = multiple;
    return _getFiles(input);
  }

  /// Convert list of XTypeGroups to a comma-separated string
  static String _acceptedTypesToString(List<XTypeGroup> acceptedTypes) {
    if (acceptedTypes == null) return '';
    final List<String> allTypes = [];
    for (final group in acceptedTypes) {
      _assertTypeGroupIsValid(group);
      if (group.extensions != null) {
        allTypes.addAll(group.extensions.map(_normalizeExtension));
      }
      if (group.mimeTypes != null) {
        allTypes.addAll(group.mimeTypes);
      }
      if (group.webWildCards != null) {
        allTypes.addAll(group.webWildCards);
      }
    }
    return allTypes.join(',');
  }

  /// Creates a new input element and adds it to the cleared container.
  FileUploadInputElement _createInputElement() {
    final input = FileUploadInputElement()..id = 'file-selector-input';
    _container.children.clear();
    _container.children.add(input);
    return input;
  }

  /// For a given input, returns the files selected by an user.
  static Future<List<XFile>> _getFiles(FileUploadInputElement input) {
    final Completer<List<XFile>> _completer = Completer();

    input.onChange.first.then((_) {
      final List<XFile> files = input.files.map(_convertFileToXFile).toList();
      _completer.complete(files);
    });

    input.onError.first.then((event) {
      final ErrorEvent error = event;
      final platformException = PlatformException(
        code: error.type,
        message: error.message,
      );
      _completer.completeError(platformException);
    });

    input.click();

    return _completer.future;
  }

  /// Helper to convert an html.File to an XFile
  static XFile _convertFileToXFile(File file) => XFile(
        Url.createObjectUrl(file),
        name: file.name,
        length: file.size,
        lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
      );

  /// Make sure that at least one of its fields is populated.
  static void _assertTypeGroupIsValid(XTypeGroup group) {
    assert(
        !((group.extensions == null || group.extensions.isEmpty) &&
            (group.mimeTypes == null || group.mimeTypes.isEmpty) &&
            (group.webWildCards == null || group.webWildCards.isEmpty)),
        'At least one of extensions / mimeTypes / webWildCards is required for web.');
  }

  /// Append a dot at the beggining if it is not there png -> .png
  static String _normalizeExtension(String ext) {
    return ext.isNotEmpty && ext[0] != '.' ? '.' + ext : ext;
  }
}
