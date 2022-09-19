// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/src/dart_file_selector_api.dart';
import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for Windows.
class FileSelectorWindows extends FileSelectorPlatform {
  /// Constructor for filePicker.
  FileSelectorWindows([this._dartFileSelectorAPI]) {
    _dartFileSelectorAPI = _dartFileSelectorAPI ?? DartFileSelectorAPI();
    _api = _dartFileSelectorAPI!;
  }

  late DartFileSelectorAPI _api;
  late DartFileSelectorAPI? _dartFileSelectorAPI;

  /// Registers the Windows implementation.
  static void registerWith([DartFileSelectorAPI? filePicker]) {
    FileSelectorPlatform.instance = FileSelectorWindows(filePicker);
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String> paths = _api.getFiles(
        selectionOptions: SelectionOptions(
          allowMultiple: false,
          selectFolders: false,
          allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
        ),
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText);
    return paths.isEmpty ? null : XFile(paths.first);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths = _api.getFiles(
        selectionOptions: SelectionOptions(
          allowMultiple: true,
          selectFolders: false,
          allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
        ),
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText);
    return paths.map((String? path) => XFile(path!)).toList();
  }

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    final String? path = _api.getSavePath(
      initialDirectory: initialDirectory,
      suggestedFileName: suggestedName,
      confirmButtonText: confirmButtonText,
      selectionOptions: SelectionOptions(
        allowMultiple: false,
        selectFolders: false,
        allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
      ),
    );
    return path == null ? null : Future<String>.value(path);
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final String? path = _api.getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText);
    return path == null ? null : Future<String>.value(path);
  }
}

List<TypeGroup> _typeGroupsFromXTypeGroups(List<XTypeGroup>? xtypes) {
  return (xtypes ?? <XTypeGroup>[]).map((XTypeGroup xtype) {
    if (!xtype.allowsAny && (xtype.extensions?.isEmpty ?? true)) {
      throw ArgumentError('Provided type group $xtype does not allow '
          'all files, but does not set any of the Windows-supported filter '
          'categories. "extensions" must be non-empty for Windows if '
          'anything is non-empty.');
    }
    return TypeGroup(
        label: xtype.label ?? '', extensions: xtype.extensions ?? <String>[]);
  }).toList();
}
