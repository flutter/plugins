// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../platform_interface/file_picker_interface.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/file_picker');

/// An implementation of [FilePickerPlatform] that uses method channels.
class MethodChannelFilePicker extends FilePickerPlatform {
  /// Load file from user's computer and return it as an XFile
  @override
  Future<List<XFile>> loadFile({List<FileTypeFilterGroup> acceptedTypes}) {
    return _channel.invokeMethod<List<XFile>>(
      'loadFile',
      <String, Object> {
        'acceptedTypes': acceptedTypes,
      },
    );
  }

  /// Saves the file to user's Disk
  @override
  void saveFile(Uint8List data, {String type, String suggestedName}) async {
    await _channel.invokeMethod(
      'saveFile',
      <String, Object> {
        'type': type,
        'suggestedName': suggestedName,
      },
    );
  }
}
