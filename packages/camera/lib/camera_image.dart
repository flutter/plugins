// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'camera.dart';

/// A single color plane of image data.
///
/// The number and meaning of the planes in an image are determined by the
/// format of the Image.
class Plane {
  Plane._fromPlatformData(Map<dynamic, dynamic> data)
      : bytes = data['bytes'],
        bytesPerPixel = data['bytesPerPixel'],
        bytesPerRow = data['bytesPerRow'],
        height = data['height'],
        width = data['width'];

  /// Bytes representing this plane.
  final Uint8List bytes;

  /// The distance between adjacent pixel samples on Android, in bytes.
  ///
  /// Will be `null` on iOS.
  final int bytesPerPixel;

  /// The row stride for this color plane, in bytes.
  final int bytesPerRow;

  /// Height of the pixel buffer on iOS.
  ///
  /// Will be `null` on Android
  final int height;

  /// Width of the pixel buffer on iOS.
  ///
  /// Will be `null` on Android.
  final int width;
}

/// Group of image formats that are comparable across Android and iOS platforms.
enum ImageFormatGroup {
  /// The image format does not fit into any specific group.
  unknown,

  /// Multi-plane YUV 420 format.
  ///
  /// This format is a generic YCbCr format, capable of describing any 4:2:0
  /// chroma-subsampled planar or semiplanar buffer (but not fully interleaved),
  /// with 8 bits per color sample.
  ///
  /// On Android, this is `android.graphics.ImageFormat.YUV_420_888`. See
  /// https://developer.android.com/reference/android/graphics/ImageFormat.html#YUV_420_888
  ///
  /// On iOS, this is `kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange`. See
  /// https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers/kcvpixelformattype_420ypcbcr8biplanarvideorange?language=objc
  yuv420,
}

/// Describes how pixels are represented in an image.
class ImageFormat {
  ImageFormat._fromPlatformData(this.raw) : group = _asImageFormatGroup(raw);

  /// Describes the format group the raw image format falls into.
  final ImageFormatGroup group;

  /// Raw version of the format from the Android or iOS platform.
  ///
  /// On Android, this is an `int` from class `android.graphics.ImageFormat`. See
  /// https://developer.android.com/reference/android/graphics/ImageFormat
  ///
  /// On iOS, this is a `FourCharCode` constant from Pixel Format Identifiers.
  /// See https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers?language=objc
  final dynamic raw;
}

ImageFormatGroup _asImageFormatGroup(dynamic rawFormat) {
  if (rawFormat == 35 || rawFormat == 875704438) {
    return ImageFormatGroup.yuv420;
  } else {
    return ImageFormatGroup.unknown;
  }
}

/// A single complete image buffer from the platform camera.
///
/// This class allows for direct application access to the pixel data of an
/// Image through one or more [Uint8List]. Each buffer is encapsulated in a
/// [Plane] that describes the layout of the pixel data in that plane. The
/// [CameraImage] is not directly usable as a UI resource.
///
/// Although not all image formats are planar on iOS, we treat 1-dimensional
/// images as single planar images.
class CameraImage {
  CameraImage._fromPlatformData(Map<dynamic, dynamic> data)
      : format = ImageFormat._fromPlatformData(data['format']),
        height = data['height'],
        width = data['width'],
        planes = List<Plane>.unmodifiable(data['planes']
            .map((dynamic planeData) => Plane._fromPlatformData(planeData)));

  /// Format of the image provided.
  ///
  /// Determines the number of planes needed to represent the image, and
  /// the general layout of the pixel data in each [Uint8List].
  final ImageFormat format;

  /// Height of the image in pixels.
  ///
  /// For formats where some color channels are subsampled, this is the height
  /// of the largest-resolution plane.
  final int height;

  /// Width of the image in pixels.
  ///
  /// For formats where some color channels are subsampled, this is the width
  /// of the largest-resolution plane.
  final int width;

  /// The pixels planes for this image.
  ///
  /// The number of planes is determined by the format of the image.
  final List<Plane> planes;
}
