// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/file_selector_windows');

/// An implementation of [FileSelectorPlatform] for Windows.
class FileSelectorWindows extends FileSelectorPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

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
    _validateTypeGroups(acceptedTypeGroups);
    final List<String>? path = await _channel.invokeListMethod<String>(
      'openFile',
      <String, dynamic>{
        'acceptedTypeGroups': acceptedTypeGroups
            ?.map((XTypeGroup group) => group.toJSON())
            .toList(),
        'initialDirectory': initialDirectory,
        'confirmButtonText': confirmButtonText,
        'multiple': false,
      },
    );
    return path == null ? null : XFile(path.first);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    _validateTypeGroups(acceptedTypeGroups);
    final List<String>? pathList = await _channel.invokeListMethod<String>(
      'openFile',
      <String, dynamic>{
        'acceptedTypeGroups': acceptedTypeGroups
            ?.map((XTypeGroup group) => group.toJSON())
            .toList(),
        'initialDirectory': initialDirectory,
        'confirmButtonText': confirmButtonText,
        'multiple': true,
      },
    );
    return pathList?.map((String path) => XFile(path)).toList() ?? <XFile>[];
  }

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    _validateTypeGroups(acceptedTypeGroups);
    return _channel.invokeMethod<String>(
      'getSavePath',
      <String, dynamic>{
        'acceptedTypeGroups': acceptedTypeGroups
            ?.map((XTypeGroup group) => group.toJSON())
            .toList(),
        'initialDirectory': initialDirectory,
        'suggestedName': suggestedName,
        'confirmButtonText': confirmButtonText,
      },
    );
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return _channel.invokeMethod<String>(
      'getDirectoryPath',
      <String, dynamic>{
        'initialDirectory': initialDirectory,
        'confirmButtonText': confirmButtonText,
      },
    );
  }

  /// Throws an [ArgumentError] if any of the provided type groups are not valid
  /// for Windows.
  void _validateTypeGroups(List<XTypeGroup>? groups) {
    if (groups == null) {
      return;
    }
    for (final XTypeGroup group in groups) {
      if (!group.allowsAny && (group.extensions?.isEmpty ?? true)) {
        throw ArgumentError('Provided type group $group does not allow '
            'all files, but does not set any of the Windows-supported filter '
            'categories. "extensions" must be non-empty for Windows if '
            'anything is non-empty.');
      }
    }
  }
}
