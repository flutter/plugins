// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_platform_interface/src/types/media_selection_type.dart';

/// Options class for [ImagePickerPlatform.getMedia].
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
  /// Allows all types by default.
  final List<MediaSelectionType> types;

  /// Allow multiple items to be picked.
  /// false by default.
  final bool allowMultiple;

  /// Adjustment options specific to images only.
  final ImageAdjustmentOptions imageAdjustmentOptions;
}

/// Image specific adjustment options for [ImagePickerPlatform.getMedia], contained in [MediaSelectionOptions].
class ImageAdjustmentOptions {
  /// Construct a new ImageAdjustmentOptions instance.
  const ImageAdjustmentOptions({
    this.maxImageWidth,
    this.maxImageHeight,
    this.imageQuality,
  });

  /// If specified, a picked image will be at most [maxImageWidth] wide.
  /// Otherwise the image will be returned at its original width.
  /// Only works for images, not videos.
  final double? maxImageWidth;

  /// If specified, a picked image will be at most [maxImageHeight] tall.
  /// Otherwise the image will be returned at its original height.
  /// Only works for images, not videos.
  final double? maxImageHeight;

  /// [imageQuality] modifies the quality of a picked image, ranging
  /// from 0-100 where 100 is the original/max quality.
  /// By default, the image with the original quality will be returned.
  /// Compression is only supported for certain image types such as JPEG and
  /// on Android PNG and WebP. If compression is not supported for the image
  /// that is picked, a warning message will be logged.
  /// Only works for images, not videos.
  final int? imageQuality;
}
