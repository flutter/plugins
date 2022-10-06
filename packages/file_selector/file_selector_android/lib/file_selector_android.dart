// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'src/messages.g.dart';

/// The Android implementation of [FileSelectorPlatform].
class FileSelectorAndroid extends FileSelectorPlatform {
  /// Creates a new instance of [FileSelectorApi].
  FileSelectorAndroid() : _api = FileSelectorApi();

  /// Creates a fake implementation of [FileSelectorApi] for testing purposes.
  @visibleForTesting
  FileSelectorAndroid.useFakeApi(this._api);

  final FileSelectorApi _api;

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorAndroid();
  }

  /// Android doesn't currently support to set the Confirm Button Text nor the Initial Directory
  /// For references, please check the following link:
  /// https://developer.android.com/reference/android/content/Intent#ACTION_GET_CONTENT
  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> path = await _api.openFiles(SelectionOptions(
      allowMultiple: false,
      allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
    ));

    return path.first == null ? null : XFile(path.first!);
  }

  /// Android doesn't currently support to set the Confirm Button Text nor the Initial Directory
  /// For references, please check the following link:
  /// https://developer.android.com/reference/android/content/Intent#ACTION_GET_CONTENT
  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> paths = await _api.openFiles(SelectionOptions(
      allowMultiple: true,
      allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
    ));

    return paths.map((String? path) => XFile(path!)).toList();
  }

  /// Android doesn't currently support to set the Confirm Button Text
  /// For references, please check the following link:
  /// https://developer.android.com/reference/android/content/Intent#ACTION_OPEN_DOCUMENT_TREE
  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return _api.getDirectoryPath(initialDirectory);
  }
}

List<String?> _typeGroupsFromXTypeGroups(List<XTypeGroup>? xtypes) {
  return (xtypes ?? <XTypeGroup>[]).expand((XTypeGroup xtype) {
    if (!xtype.allowsAny && (xtype.mimeTypes?.isEmpty ?? true)) {
      throw ArgumentError('Provided type group $xtype does not allow '
          'all files, but does not set any of the Android-supported filter '
          'categories. "mimeTypes" must be non-empty for Android if '
          'anything is non-empty.');
    }
    return xtype.mimeTypes!;
  }).toList();
}
