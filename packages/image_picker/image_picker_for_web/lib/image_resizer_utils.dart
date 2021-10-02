// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:ui';

///a function that checks if an image needs to be resized or not
bool imageResizeNeeded(double? maxWidth, double? maxHeight, int? imageQuality) {
  return imageQuality != null
      ? isImageQualityValid(imageQuality)
      : (maxWidth != null || maxHeight != null);
}

/// a function that checks if image quality is between 0 to 100
bool isImageQualityValid(int imageQuality) {
  return (imageQuality >= 0 && imageQuality <= 100);
}

/// a functions that calculates the size of the downScaled image.
/// imageWidth is the width of the image
/// imageHeight is the height of  the image
/// maxWidth is the maximum width of the scaled image
/// maxHeight is the maximum height of the scaled image
Size calculateSizeOfDownScaledImage(
    Size imageSize, double? maxWidth, double? maxHeight) {
  double originalWidth = imageSize.width;
  double originalHeight = imageSize.height;

  bool hasMaxWidth = maxWidth != null;
  bool hasMaxHeight = maxHeight != null;
  double width = hasMaxWidth ? min(maxWidth, originalWidth) : originalWidth;
  double height =
      hasMaxHeight ? min(maxHeight, originalHeight) : originalHeight;
  bool shouldDownscaleWidth = hasMaxWidth && maxWidth < originalWidth;
  bool shouldDownscaleHeight = hasMaxHeight && maxHeight < originalHeight;
  bool shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;
  if (shouldDownscale) {
    double downscaledWidth =
        ((height / originalHeight) * originalWidth).floorToDouble();
    double downscaledHeight =
        ((width / originalWidth) * originalHeight).floorToDouble();

    if (width < height) {
      if (!hasMaxWidth) {
        width = downscaledWidth;
      } else {
        height = downscaledHeight;
      }
    } else if (height < width) {
      if (!hasMaxHeight) {
        height = downscaledHeight;
      } else {
        width = downscaledWidth;
      }
    } else {
      if (originalWidth < originalHeight) {
        width = downscaledWidth;
      } else if (originalHeight < originalWidth) {
        height = downscaledHeight;
      }
    }
  }
  return Size(width, height);
}
