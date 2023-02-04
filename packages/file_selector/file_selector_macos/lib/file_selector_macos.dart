// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for macOS.
class FileSelectorMacOS extends FileSelectorPlatform {
  final FileSelectorApi _hostApi = FileSelectorApi();

  /// Registers the macOS implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorMacOS();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths =
        await _hostApi.displayOpenPanel(OpenPanelOptions(
            allowsMultipleSelection: false,
            canChooseDirectories: false,
            canChooseFiles: true,
            baseOptions: SavePanelOptions(
              allowedFileTypes: _allowedTypesFromTypeGroups(acceptedTypeGroups),
              directoryPath: initialDirectory,
              prompt: confirmButtonText,
            )));
    return paths.isEmpty ? null : XFile(paths.first!);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths =
        await _hostApi.displayOpenPanel(OpenPanelOptions(
            allowsMultipleSelection: true,
            canChooseDirectories: false,
            canChooseFiles: true,
            baseOptions: SavePanelOptions(
              allowedFileTypes: _allowedTypesFromTypeGroups(acceptedTypeGroups),
              directoryPath: initialDirectory,
              prompt: confirmButtonText,
            )));
    return paths.map((String? path) => XFile(path!)).toList();
  }

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    return _hostApi.displaySavePanel(SavePanelOptions(
      allowedFileTypes: _allowedTypesFromTypeGroups(acceptedTypeGroups),
      directoryPath: initialDirectory,
      nameFieldStringValue: suggestedName,
      prompt: confirmButtonText,
    ));
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths =
        await _hostApi.displayOpenPanel(OpenPanelOptions(
            allowsMultipleSelection: false,
            canChooseDirectories: true,
            canChooseFiles: false,
            baseOptions: SavePanelOptions(
              directoryPath: initialDirectory,
              prompt: confirmButtonText,
            )));
    return paths.isEmpty ? null : paths.first;
  }

  // Converts the type group list into a flat list of all allowed types, since
  // macOS doesn't support filter groups.
  AllowedTypes? _allowedTypesFromTypeGroups(List<XTypeGroup>? typeGroups) {
    if (typeGroups == null || typeGroups.isEmpty) {
      return null;
    }
    final AllowedTypes allowedTypes = AllowedTypes(
      extensions: <String>[],
      mimeTypes: <String>[],
      utis: <String>[],
    );
    for (final XTypeGroup typeGroup in typeGroups) {
      // If any group allows everything, no filtering should be done.
      if (typeGroup.allowsAny) {
        return null;
      }
      // Reject a filter that isn't an allow-any, but doesn't set any
      // macOS-supported filter categories.
      if ((typeGroup.extensions?.isEmpty ?? true) &&
          (typeGroup.macUTIs?.isEmpty ?? true) &&
          (typeGroup.mimeTypes?.isEmpty ?? true)) {
        throw ArgumentError('Provided type group $typeGroup does not allow '
            'all files, but does not set any of the macOS-supported filter '
            'categories. At least one of "extensions", "macUTIs", or '
            '"mimeTypes" must be non-empty for macOS if anything is '
            'non-empty.');
      }
      allowedTypes.extensions.addAll(typeGroup.extensions ?? <String>[]);
      allowedTypes.mimeTypes.addAll(typeGroup.mimeTypes ?? <String>[]);
      allowedTypes.utis.addAll(typeGroup.macUTIs ?? <String>[]);
    }

    return allowedTypes;
  }
}
