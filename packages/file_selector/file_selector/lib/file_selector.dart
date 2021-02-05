// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
export 'package:file_selector_platform_interface/file_selector_platform_interface.dart'
    show XFile, XTypeGroup;

/// Open file dialog for loading files and return a file path
Future<XFile?> openFile({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? confirmButtonText,
}) {
  acceptedTypeGroups = _verifyTypeGroups(acceptedTypeGroups);
  return FileSelectorPlatform.instance.openFile(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText);
}

/// Open file dialog for loading files and return a list of file paths
Future<List<XFile>> openFiles({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? confirmButtonText,
}) {
  acceptedTypeGroups = _verifyTypeGroups(acceptedTypeGroups);
  return FileSelectorPlatform.instance.openFiles(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText);
}

/// Saves File to user's file system
Future<String?> getSavePath({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? suggestedName,
  String? confirmButtonText,
}) async {
  acceptedTypeGroups = _verifyTypeGroups(acceptedTypeGroups);
  return FileSelectorPlatform.instance.getSavePath(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      suggestedName: suggestedName,
      confirmButtonText: confirmButtonText);
}

/// Gets a directory path from a user's file system
Future<String?> getDirectoryPath({
  String? initialDirectory,
  String? confirmButtonText,
}) async {
  return FileSelectorPlatform.instance.getDirectoryPath(
      initialDirectory: initialDirectory, confirmButtonText: confirmButtonText);
}

List<XTypeGroup> _verifyTypeGroups(List<XTypeGroup> groups) {
  if (groups == null) return groups;
  for (var i = 0; i < groups.length; i++) {
    if (groups[i] == null || groups[i].extensions == null) continue;
    for (var j = 0; j < groups[i].extensions.length; j++) {
      if (groups[i].extensions[j] == null) continue;
      if (groups[i].extensions[j].startsWith('.')) {
        if (kDebugMode) {
          print('acceptedTypeGroups[${i}].extensions[${j}]'
              ' with value "${groups[i].extensions[j]} is invalid.'
              ' Please remove the leading dot.');
        }
        groups[i].extensions[j] = groups[i].extensions[j].substring(1);
      }
    }
  }
  return groups;
}
