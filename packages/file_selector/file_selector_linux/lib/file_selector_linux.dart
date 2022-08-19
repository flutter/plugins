// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.dev/file_selector_linux');

const String _typeGroupLabelKey = 'label';
const String _typeGroupExtensionsKey = 'extensions';
const String _typeGroupMimeTypesKey = 'mimeTypes';

const String _openFileMethod = 'openFile';
const String _getSavePathMethod = 'getSavePath';
const String _getDirectoryPathMethod = 'getDirectoryPath';

const String _acceptedTypeGroupsKey = 'acceptedTypeGroups';
const String _confirmButtonTextKey = 'confirmButtonText';
const String _initialDirectoryKey = 'initialDirectory';
const String _multipleKey = 'multiple';
const String _suggestedNameKey = 'suggestedName';

/// An implementation of [FileSelectorPlatform] for Linux.
class FileSelectorLinux extends FileSelectorPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  /// Registers the Linux implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorLinux();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<Map<String, Object>> serializedTypeGroups =
        _serializeTypeGroups(acceptedTypeGroups);
    final List<String>? path = await _channel.invokeListMethod<String>(
      _openFileMethod,
      <String, dynamic>{
        if (serializedTypeGroups.isNotEmpty)
          _acceptedTypeGroupsKey: serializedTypeGroups,
        'initialDirectory': initialDirectory,
        _confirmButtonTextKey: confirmButtonText,
        _multipleKey: false,
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
    final List<Map<String, Object>> serializedTypeGroups =
        _serializeTypeGroups(acceptedTypeGroups);
    final List<String>? pathList = await _channel.invokeListMethod<String>(
      _openFileMethod,
      <String, dynamic>{
        if (serializedTypeGroups.isNotEmpty)
          _acceptedTypeGroupsKey: serializedTypeGroups,
        _initialDirectoryKey: initialDirectory,
        _confirmButtonTextKey: confirmButtonText,
        _multipleKey: true,
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
    final List<Map<String, Object>> serializedTypeGroups =
        _serializeTypeGroups(acceptedTypeGroups);
    return _channel.invokeMethod<String>(
      _getSavePathMethod,
      <String, dynamic>{
        if (serializedTypeGroups.isNotEmpty)
          _acceptedTypeGroupsKey: serializedTypeGroups,
        _initialDirectoryKey: initialDirectory,
        _suggestedNameKey: suggestedName,
        _confirmButtonTextKey: confirmButtonText,
      },
    );
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return _channel.invokeMethod<String>(
      _getDirectoryPathMethod,
      <String, dynamic>{
        _initialDirectoryKey: initialDirectory,
        _confirmButtonTextKey: confirmButtonText,
      },
    );
  }
}

List<Map<String, Object>> _serializeTypeGroups(List<XTypeGroup>? groups) {
  return (groups ?? <XTypeGroup>[]).map(_serializeTypeGroup).toList();
}

Map<String, Object> _serializeTypeGroup(XTypeGroup group) {
  final Map<String, Object> serialization = <String, Object>{
    _typeGroupLabelKey: group.label ?? '',
  };
  if (group.allowsAny) {
    serialization[_typeGroupExtensionsKey] = <String>['*'];
  } else {
    if ((group.extensions?.isEmpty ?? true) &&
        (group.mimeTypes?.isEmpty ?? true)) {
      throw ArgumentError('Provided type group $group does not allow '
          'all files, but does not set any of the Linux-supported filter '
          'categories. "extensions" or "mimeTypes" must be non-empty for Linux '
          'if anything is non-empty.');
    }
    if (group.extensions?.isNotEmpty ?? false) {
      serialization[_typeGroupExtensionsKey] = group.extensions
              ?.map((String extension) => '*.$extension')
              .toList() ??
          <String>[];
    }
    if (group.mimeTypes?.isNotEmpty ?? false) {
      serialization[_typeGroupMimeTypesKey] = group.mimeTypes ?? <String>[];
    }
  }
  return serialization;
}
