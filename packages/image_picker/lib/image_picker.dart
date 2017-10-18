// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ImagePicker {
  static const MethodChannel _channel = const MethodChannel('image_picker');

  /// Returns a [File] object pointing to the image that was picked.
  ///
  /// On both Android & iOS, the user can choose to either:
  ///
  /// * pick an image from the gallery
  /// * take a photo using the device camera.
  ///
  /// If specified, image will be resized to [desiredWidth] and [desiredHeight].
  static Future<File> pickImage({double desiredWidth, double desiredHeight}) async {
    final String path = await _channel.invokeMethod('pickImage',
      <String, double> {
        'width': desiredWidth,
        'height': desiredHeight,
      },
    );
    return new File(path);
  }
}
