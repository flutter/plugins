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
  /// If specified, the image will be at most [maxWidth] wide and
  /// [maxHeight] tall. Otherwise the image will be returned at it's
  /// original width and height.
  static Future<File> pickImage({double maxWidth, double maxHeight}) async {
    if (maxWidth != null && maxWidth < 0) {
      throw new ArgumentError.value(maxWidth, 'maxWidth can\'t be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw new ArgumentError.value(maxHeight, 'maxHeight can\'t be negative');
    }

    final String path = await _channel.invokeMethod(
      'pickImage',
      <String, double>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      },
    );

    return new File(path);
  }
}
