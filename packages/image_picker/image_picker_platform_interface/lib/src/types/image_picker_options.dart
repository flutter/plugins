// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:image_picker_platform_interface/src/types/types.dart';

/// Specifies options for picking a single image from the device's camera or gallery.
class ImagePickerOptions {
  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality],
  /// [referredCameraDevice] and [requestFullMetadata]. Any of the params may be null.
  const ImagePickerOptions({
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
    this.requestFullMetadata = true,
  });

  /// If specified, the image will be at most `maxWidth` wide. Otherwise,
  /// the image will be returned at its original width.
  final double? maxWidth;

  /// If specified, the image will be at most`maxHeight` tall.
  /// Otherwise the image will be returned at its original height.
  final double? maxHeight;

  /// Modifies the quality of the image, ranging from 0-100 where 100 is the original/max
  /// quality. If `imageQuality` is null, the image with the originalquality will
  /// be returned. Compression is only supported for certain image types such as
  /// JPEG. If compression is not supported for the image that is picked, a warning
  /// message will be logged.
  final int? imageQuality;

  /// Used to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery].
  /// It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear]. Note that Android has no documented parameter
  /// for an intent to specify if the front or rear camera should be opened, this
  /// function is not guaranteed to work on an Android device.
  final CameraDevice preferredCameraDevice;

  /// `requestFullMetadata` defaults to `true`, so the plugin tries to get the
  /// full image metadata which may require extra permission requests on certain platforms.
  /// If `requestFullMetadata` is set to `false`, the plugin fetches the image
  /// in a way that reduces permission requests from the platform (e.g. on iOS
  /// the plugin won’t ask for the `NSPhotoLibraryUsageDescription` permission).
  final bool requestFullMetadata;
}
