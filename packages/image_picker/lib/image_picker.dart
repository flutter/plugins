// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Specifies the source where the picked image should come from.
enum ImageSource {
  /// Let the user choose an image from a source they prefer.
  ///
  /// On Android, opens a new screen with a grid of images (from the users
  /// gallery) and a camera icon on the top right corner. The user can
  /// either pick an image from the image grid, or tap the camera icon
  /// to take a picture using the device camera.
  ///
  /// On iOS, the user is presented with an alert box with options to
  /// either take a photo using the device camera or pick an image from
  /// the photo library.
  askUser,

  /// Opens up the device camera on both Android and iOS.
  camera,

  /// On Android, presents a grid of images from the users gallery. On iOS,
  /// opens the users photo library.
  gallery,
}

class ImagePicker {
  static const MethodChannel _channel = const MethodChannel('image_picker');

  /// Returns a [File] object pointing to the image that was picked.
  ///
  /// On both Android & iOS, the user can choose to either:
  ///
  /// * pick an image from the gallery
  /// * take a photo using the device camera.
  ///
  /// Use the [source] argument for controlling where the image comes from.
  /// By default, the user can choose the image from either camera or gallery.
  ///
  /// If specified, the image will be at most [maxWidth] wide and
  /// [maxHeight] tall. Otherwise the image will be returned at it's
  /// original width and height.
  static Future<File> pickImage({
    ImageSource source = ImageSource.askUser,
    double maxWidth,
    double maxHeight,
  }) async {
    assert(source != null);

    if (maxWidth != null && maxWidth < 0) {
      throw new ArgumentError.value(maxWidth, 'maxWidth can\'t be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw new ArgumentError.value(maxHeight, 'maxHeight can\'t be negative');
    }

    final String path = await _channel.invokeMethod(
      'pickImage',
      <String, dynamic>{
        'source': source.index,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      },
    );

    return new File(path);
  }
}
