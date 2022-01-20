// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/src/dom_helper.dart';
import 'package:file_selector_web/src/utils.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The web implementation of [FileSelectorPlatform].
///
/// This class implements the `package:file_selector` functionality for the web.
class FileSelectorWeb extends FileSelectorPlatform {
  /// Default constructor, initializes _domHelper that we can use
  /// to interact with the DOM.
  /// overrides parameter allows for testing to override functions
  FileSelectorWeb({@visibleForTesting DomHelper? domHelper})
      : _domHelper = domHelper ?? DomHelper();

  final DomHelper _domHelper;

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith(Registrar registrar) {
    FileSelectorPlatform.instance = FileSelectorWeb();
  }

  @override
  Future<XFile> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<XFile> files =
        await _openFiles(acceptedTypeGroups: acceptedTypeGroups);
    return files.first;
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return _openFiles(acceptedTypeGroups: acceptedTypeGroups, multiple: true);
  }

  // This is intended to be passed to XFile, which ignores the path, but 'null'
  // indicates a canceled save on other platforms, so provide a non-null dummy
  // value.
  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async =>
      '';

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async =>
      null;

  Future<List<XFile>> _openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    bool multiple = false,
  }) async {
    final String accept = acceptedTypesToString(acceptedTypeGroups);
    return _domHelper.getFiles(
      accept: accept,
      multiple: multiple,
    );
  }
}
