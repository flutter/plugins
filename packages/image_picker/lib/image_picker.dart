// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Specifies the source where the picked image should come from.
enum ImageSource {
  /// Opens up the device camera, letting the user to take a new picture.
  camera,

  /// Opens the user's photo gallery.
  gallery,
}

class ImagePicker {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/image_picker');

  /// Returns a [File] object pointing to the image that was picked.
  ///
  /// The [source] argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// If specified, the image will be at most [maxWidth] wide and
  /// [maxHeight] tall. Otherwise the image will be returned at it's
  /// original width and height.
  ///
  /// If [crop] is false, then image will be downscaled until both dimensions
  /// satisfy the limits. If [crop] is true, then image will be downscaled
  /// until any of dimensions satisfies the limits and another one will be
  /// cropped.
  static Future<File> pickImage({
    @required ImageSource source,
    double maxWidth,
    double maxHeight,
    bool crop = false,
  }) async {
    assert(source != null);
    assert(crop != null);

    if (maxWidth != null && maxWidth <= 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth must be positive');
    }

    if (maxHeight != null && maxHeight <= 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight must be positive');
    }

    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String path = await _channel.invokeMethod(
      'pickImage',
      <String, dynamic>{
        'source': source.index,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'crop': crop
      },
    );

    return path == null ? null : File(path);
  }

  static Future<File> pickVideo({
    @required ImageSource source,
  }) async {
    assert(source != null);

    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String path = await _channel.invokeMethod(
      'pickVideo',
      <String, dynamic>{
        'source': source.index,
      },
    );
    return path == null ? null : File(path);
  }
}
