// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

export 'package:file_picker_platform_interface/file_picker_platform_interface.dart'
  show XFile, FileTypeFilterGroup;

/// NEW API

/// Open file dialog for loading files and return a file path
XPath getReadPath({List<FileTypeFilterGroup> acceptedTypes}) {
  return FilePickerPlatform.instance.getReadPath(acceptedTypes: acceptedTypes);
}

/// Open file dialog for loading files and return a list of file paths
List<XPath> getReadPaths({List<FileTypeFilterGroup> acceptedTypes}) {
  return FilePickerPlatform.instance.getReadPaths(acceptedTypes: acceptedTypes);
}

/// Open file dialog for saving files and return a file path at which to save
XPath getSavePath() {
  throw UnimplementedError('loadFile() has not been implemented.');
}


/// OLD API

/// Saves File to user's file system
void saveFile(Uint8List data, {String type = '', String suggestedName}) async {
  return FilePickerPlatform.instance.saveFile(data, type: type, suggestedName: suggestedName);
}

/// Loads File from user's file system
Future<List<XFile>> loadFile({List<FileTypeFilterGroup> acceptedTypes}) {
  return FilePickerPlatform.instance.loadFile(acceptedTypes: acceptedTypes);
}