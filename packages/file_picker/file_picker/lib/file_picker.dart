// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

export 'package:file_picker_platform_interface/file_picker_platform_interface.dart'
  show XFile, FileTypeFilterGroup;

/// Saves File to user's file system
void saveFile(Uint8List data, {String type = '', String suggestedName}) async {
  return FilePickerPlatform.instance.saveFile(data, type: type, suggestedName: suggestedName);
}

/// Loads File from user's file system
Future<List<XFile>> loadFile({List<FileTypeFilterGroup> acceptedTypes}) {
  return FilePickerPlatform.instance.loadFile(acceptedTypes: acceptedTypes);
}