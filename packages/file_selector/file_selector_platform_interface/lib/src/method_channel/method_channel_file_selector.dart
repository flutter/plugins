// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/file_picker');

/// An implementation of [FileSelectorPlatform] that uses method channels.
class MethodChannelFileSelector extends FileSelectorPlatform {
  /// Load a file from user's computer and return it as an XFile
  @override
  Future<XFile> openFile({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String confirmButtonText,
  }) async {
    String path = await _channel.invokeMethod<String>(
      'openFiles',
      <String, Object>{
        'acceptedTypes': acceptedTypeGroups,
        'initialDirectory': initialDirectory,
        'multiple': false,
      },
    );
    return XFile(path);
  }

  /// Load multiple files from user's computer and return it as an XFile
  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String confirmButtonText,
  }) async {
    final pathList = await _channel.invokeMethod<List<String>>(
      'openFiles',
      <String, Object>{
        'acceptedTypes': acceptedTypeGroups,
        'initialDirectory': initialDirectory,
        'multiple': true,
      },
    );
    return pathList.map((path) => XFile(path)).toList();
  }

  /// Saves the file to user's Disk
  @override
  Future<String> getSavePath({
    List<XTypeGroup> acceptedTypeGroups,
    String initialDirectory,
    String suggestedName,
    String confirmButtonText,
  }) async {
    return _channel.invokeMethod<String>(
      'saveFile',
      <String, Object>{
        'initialDirectory': initialDirectory,
        'suggestedName': suggestedName,
      },
    );
  }
}
