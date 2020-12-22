// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/src/dom_helper.dart';

/// The web implementation of [FileSelectorPlatform].
///
/// This class implements the `package:file_selector` functionality for the web.
class FileSelectorWeb extends FileSelectorPlatform {
  final _domHelper;

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith(Registrar registrar) {
    FileSelectorPlatform.instance = FileSelectorWeb();
  }

  /// Default constructor, initializes _domHelper that we can use
  /// to interact with the DOM.
  /// overrides parameter allows for testing to override functions
  FileSelectorWeb({@visibleForTesting DomHelper domHelper})
      : _domHelper = domHelper ?? DomHelper();

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
    final List<File> files = await _domHelper.getFilesFromInput(
      accept: accept,
      multiple: multiple,
    );
    return files.map(_convertFileToXFile).toList();
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

  /// Make sure that at least one of its fields is populated.
  static void _assertTypeGroupIsValid(XTypeGroup group) {
    assert(
        !((group.extensions == null || group.extensions.isEmpty) &&
            (group.mimeTypes == null || group.mimeTypes.isEmpty) &&
            (group.webWildCards == null || group.webWildCards.isEmpty)),
        'At least one of extensions / mimeTypes / webWildCards is required for web.');
  }

  /// Helper to convert an html.File to an XFile
  static XFile _convertFileToXFile(File file) => XFile(
        Url.createObjectUrl(file),
        name: file.name,
        length: file.size,
        lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
      );

  /// Append a dot at the beggining if it is not there png -> .png
  static String _normalizeExtension(String ext) {
    return ext.isNotEmpty && ext[0] != '.' ? '.' + ext : ext;
  }
}
