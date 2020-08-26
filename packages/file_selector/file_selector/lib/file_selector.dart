// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

export 'package:file_selector_platform_interface/file_selector_platform_interface.dart'
  show XFile, XTypeGroup;

/// NEW API

/// Open file dialog for loading files and return a file path
Future<XFile> loadFile({
  List<XTypeGroup> acceptedTypeGroups,
  String initialDirectory,
}) {
  return FileSelectorPlatform.instance.loadFile(acceptedTypeGroups: acceptedTypeGroups, initialDirectory: initialDirectory);
}

/// Open file dialog for loading files and return a list of file paths
Future<List<XFile>> loadFiles({
  List<XTypeGroup> acceptedTypeGroups,
  String initialDirectory,
}) {
  return FileSelectorPlatform.instance.loadFiles(acceptedTypeGroups: acceptedTypeGroups, initialDirectory: initialDirectory);
}

/// Saves File to user's file system
Future<String> getSavePath({
  String initialDirectory,
  String suggestedName,
}) async {
  return FileSelectorPlatform.instance.getSavePath(initialDirectory: initialDirectory, suggestedName: suggestedName);
}