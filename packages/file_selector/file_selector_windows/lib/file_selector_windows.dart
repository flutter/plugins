// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

import 'src/file_selector_api.dart';
import 'src/file_selector_dart/dialog_wrapper_factory.dart';
import 'src/file_selector_dart/file_dialog_controller_factory.dart';
import 'src/file_selector_dart/ifile_dialog_factory.dart';
import 'src/file_selector_dart/selection_options.dart';

/// An implementation of [FileSelectorPlatform] for Windows.
class FileSelectorWindows extends FileSelectorPlatform {
  /// Creates a new instance of [FileSelectorApi].
  FileSelectorWindows()
      : _hostApi = FileSelectorApi(
            DialogWrapperFactory(
              FileDialogControllerFactory(),
              IFileDialogFactory(),
            ),
            GetActiveWindow());

  /// Creates a fake implementation of [FileSelectorApi] for testing purposes.
  @visibleForTesting
  FileSelectorWindows.useFakeApi(this._hostApi);

  final FileSelectorApi _hostApi;

  /// Registers the Windows implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorWindows();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths = _hostApi.showOpenDialog(
      SelectionOptions(allowedTypes: _allowedXTypeGroups(acceptedTypeGroups)),
      initialDirectory,
      confirmButtonText,
    );
    return paths.isEmpty ? null : XFile(paths.first!);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths = _hostApi.showOpenDialog(
      SelectionOptions(
          allowMultiple: true,
          allowedTypes: _allowedXTypeGroups(acceptedTypeGroups)),
      initialDirectory,
      confirmButtonText,
    );
    return paths.map((String? path) => XFile(path!)).toList();
  }

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    final List<String?> paths = _hostApi.showSaveDialog(
      SelectionOptions(allowedTypes: _allowedXTypeGroups(acceptedTypeGroups)),
      initialDirectory,
      suggestedName,
      confirmButtonText,
    );
    return paths.isEmpty ? null : paths.first!;
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths = _hostApi.showOpenDialog(
      SelectionOptions(selectFolders: true, allowedTypes: <XTypeGroup>[]),
      initialDirectory,
      confirmButtonText,
    );
    return paths.isEmpty ? null : paths.first!;
  }
}

List<XTypeGroup> _allowedXTypeGroups(List<XTypeGroup>? xtypes) {
  return (xtypes ?? <XTypeGroup>[]).map((XTypeGroup xtype) {
    if (!xtype.allowsAny && (xtype.extensions?.isEmpty ?? true)) {
      throw ArgumentError('Provided type group $xtype does not allow '
          'all files, but does not set any of the Windows-supported filter '
          'categories. "extensions" must be non-empty for Windows if '
          'anything is non-empty.');
    }
    return xtype;
  }).toList();
}
