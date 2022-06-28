// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Specifies options class for selecting items when using [ImagePickerPlatform.getMedia].
class MediaSelectionOptions {
  /// Construct a new MediaSelectionOptions instance.
  MediaSelectionOptions({
    List<MediaSelectionType>? types,
    this.allowMultiple = false,
    this.imageAdjustmentOptions = const ImageAdjustmentOptions(),
  }) : types = types ??
            <MediaSelectionType>[
              MediaSelectionType.image,
              MediaSelectionType.video
            ];

  /// The types of allowed media to be picked.
  ///
  /// Allows all types by default.
  final List<MediaSelectionType> types;

  /// Allow multiple items to be picked.
  ///
  /// false by default.
  final bool allowMultiple;

  /// Adjustment options specific to images only.
  final ImageAdjustmentOptions imageAdjustmentOptions;
}

/// Image specific adjustment options for [ImagePickerPlatform.getMedia], contained in [MediaSelectionOptions].
class ImageAdjustmentOptions {
  /// Construct a new ImageAdjustmentOptions instance.
  const ImageAdjustmentOptions({
    this.maxWidth,
    this.maxHeight,
    this.quality,
  });

  /// If specified, a picked image will be at most [maxWidth] wide.
  ///
  /// Otherwise the image will be returned at its original width.
  final double? maxWidth;

  /// If specified, a picked image will be at most [maxHeight] tall.
  ///
  /// Otherwise the image will be returned at its original height.
  final double? maxHeight;

  /// [quality] modifies the quality of a picked image, ranging from 0-100 where 100 is the original/max quality.
  ///
  /// By default, the image with the original quality will be returned.
  /// Compression is only supported for certain image types such as JPEG and
  /// on Android PNG and WebP. If compression is not supported for the image
  /// that is picked, a warning message will be logged.
  final int? quality;
}
