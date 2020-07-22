// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

export 'package:file_picker_platform_interface/file_picker_platform_interface.dart'
  show XFile;

/// Gets message from platform implementation
Future<String> getMessage() async {
  final String result = await FilePickerPlatform.instance.getMessage();
  return result;
}

/// Saves File to user's file system
void saveFile(Uint8List data, {String suggestedName}) async {
  return FilePickerPlatform.instance.saveFile(data, suggestedName: suggestedName);
}

/// Loads File from user's file system
Future<XFile> loadFile() {
  return FilePickerPlatform.instance.loadFile();
}