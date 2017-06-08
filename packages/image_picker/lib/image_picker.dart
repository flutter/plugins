// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ImagePicker {
  static const MethodChannel _channel = const MethodChannel('image_picker');

  // Returns the URL of the picked image
  static Future<File> pickImage() async {
    final String path = await _channel.invokeMethod('pickImage');
    return new File(path);
  }
}
