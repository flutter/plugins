// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

import '../../file_selector_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/file_selector');

/// An implementation of [FileSelectorPlatform] that uses method channels.
class MethodChannelFileSelector extends FileSelectorPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  /// Load a file from user's computer and return it as an XFile
  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
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

  /// Load multiple files from user's computer and return it as an XFile
  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
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

  /// Gets the path from a save dialog
  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
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

  /// Gets a directory path from a dialog
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

  /// Gets a list of directories paths from a dialog
  @override
  Future<List<String>?> getDirectoryPaths(
      {String? initialDirectory, String? confirmButtonText}) async {
    return _channel.invokeListMethod<String>(
      'getDirectoryPaths',
      <String, dynamic>{
        'initialDirectory': initialDirectory,
        'confirmButtonText': confirmButtonText,
        'multiple': true,
      },
    );
  }
}
