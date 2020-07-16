// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required;

import 'file_picker_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/file_picker');

/// An implementation of [FilePickerPlatform] that uses method channels.
class MethodChannelFilePicker extends FilePickerPlatform {

  @override
  Future<String> getMessage() {
    return _channel.invokeMethod<String>('getMessage');
  }
}
