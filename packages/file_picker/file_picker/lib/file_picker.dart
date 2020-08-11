// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

export 'package:file_picker_platform_interface/file_picker_platform_interface.dart'
  show XFile, FileTypeFilterGroup, XPath;

/// NEW API

/// Open file dialog for loading files and return a file path
Future<XFile> loadFile({List<FileTypeFilterGroup> acceptedTypes}) {
  return FilePickerPlatform.instance.loadFile(acceptedTypes: acceptedTypes);
}

/// Open file dialog for loading files and return a list of file paths
Future<List<XFile>> loadFiles({List<FileTypeFilterGroup> acceptedTypes}) {
  return FilePickerPlatform.instance.loadFiles(acceptedTypes: acceptedTypes);
}

/// Saves File to user's file system
Future<String> getSavePath() async {
  return FilePickerPlatform.instance.getSavePath();
}