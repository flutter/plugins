// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

export 'package:image_picker_platform_interface/image_picker_platform_interface.dart'
    show
        kTypeImage,
        kTypeVideo,
        ImageSource,
        CameraDevice,
        LostData,
        LostDataResponse,
        PickedFile,
        RetrieveType;

/// Provides an easy way to pick an image/video from the image library,
/// or to take a picture/video with the camera.
class ImagePicker {
  /// The platform interface that drives this plugin
  @visibleForTesting
  static ImagePickerPlatform platform = ImagePickerPlatform.instance;

  /// Returns a [File] object pointing to the image that was picked.
  ///
  /// The returned [File] is intended to be used within a single APP session. Do not save the file path and use it across sessions.
  ///
  /// The `source` argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// If specified, the image will be at most `maxWidth` wide and
  /// `maxHeight` tall. Otherwise the image will be returned at it's
  /// original width and height.
  /// The `imageQuality` argument modifies the quality of the image, ranging from 0-100
  /// where 100 is the original/max quality. If `imageQuality` is null, the image with
  /// the original quality will be returned. Compression is only supportted for certain
  /// image types such as JPEG. If compression is not supported for the image that is picked,
  /// an warning message will be logged.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// In Android, the MainActivity can be destroyed for various reasons. If that happens, the result will be lost
  /// in this call. You can then call [retrieveLostData] when your app relaunches to retrieve the lost data.
  @Deprecated('Use imagePicker.getImage() method instead.')
  static Future<File> pickImage(
      {@required ImageSource source,
      double maxWidth,
      double maxHeight,
      int imageQuality,
      CameraDevice preferredCameraDevice = CameraDevice.rear}) async {
    String path = await platform.pickImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );

    return path == null ? null : File(path);
  }

  /// Returns a [PickedFile] object wrapping the image that was picked.
  ///
  /// The returned [PickedFile] is intended to be used within a single APP session. Do not save the file path and use it across sessions.
  ///
  /// The `source` argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// If specified, the image will be at most `maxWidth` wide and
  /// `maxHeight` tall. Otherwise the image will be returned at it's
  /// original width and height.
  /// The `imageQuality` argument modifies the quality of the image, ranging from 0-100
  /// where 100 is the original/max quality. If `imageQuality` is null, the image with
  /// the original quality will be returned. Compression is only supportted for certain
  /// image types such as JPEG. If compression is not supported for the image that is picked,
  /// an warning message will be logged.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// In Android, the MainActivity can be destroyed for various reasons. If that happens, the result will be lost
  /// in this call. You can then call [getLostData] when your app relaunches to retrieve the lost data.
  Future<PickedFile> getImage({
    @required ImageSource source,
    double maxWidth,
    double maxHeight,
    int imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    return platform.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  /// Returns a [File] object pointing to the video that was picked.
  ///
  /// The returned [File] is intended to be used within a single APP session. Do not save the file path and use it across sessions.
  ///
  /// The [source] argument controls where the video comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// The [maxDuration] argument specifies the maximum duration of the captured video. If no [maxDuration] is specified,
  /// the maximum duration will be infinite.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// In Android, the MainActivity can be destroyed for various fo reasons. If that happens, the result will be lost
  /// in this call. You can then call [retrieveLostData] when your app relaunches to retrieve the lost data.
  @Deprecated('Use imagePicker.getVideo() method instead.')
  static Future<File> pickVideo(
      {@required ImageSource source,
      CameraDevice preferredCameraDevice = CameraDevice.rear,
      Duration maxDuration}) async {
    String path = await platform.pickVideoPath(
      source: source,
      preferredCameraDevice: preferredCameraDevice,
      maxDuration: maxDuration,
    );

    return path == null ? null : File(path);
  }

  /// Returns a [PickedFile] object wrapping the video that was picked.
  ///
  /// The returned [PickedFile] is intended to be used within a single APP session. Do not save the file path and use it across sessions.
  ///
  /// The [source] argument controls where the video comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// The [maxDuration] argument specifies the maximum duration of the captured video. If no [maxDuration] is specified,
  /// the maximum duration will be infinite.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// In Android, the MainActivity can be destroyed for various fo reasons. If that happens, the result will be lost
  /// in this call. You can then call [getLostData] when your app relaunches to retrieve the lost data.
  Future<PickedFile> getVideo({
    @required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration maxDuration,
  }) {
    return platform.pickVideo(
      source: source,
      preferredCameraDevice: preferredCameraDevice,
      maxDuration: maxDuration,
    );
  }

  /// Retrieve the lost image file when [pickImage] or [pickVideo] failed because the  MainActivity is destroyed. (Android only)
  ///
  /// Image or video can be lost if the MainActivity is destroyed. And there is no guarantee that the MainActivity is always alive.
  /// Call this method to retrieve the lost data and process the data according to your APP's business logic.
  ///
  /// Returns a [LostDataResponse] if successfully retrieved the lost data. The [LostDataResponse] can represent either a
  /// successful image/video selection, or a failure.
  ///
  /// Calling this on a non-Android platform will throw [UnimplementedError] exception.
  ///
  /// See also:
  /// * [LostDataResponse], for what's included in the response.
  /// * [Android Activity Lifecycle](https://developer.android.com/reference/android/app/Activity.html), for more information on MainActivity destruction.
  static Future<LostDataResponse> retrieveLostData() {
    return platform.retrieveLostDataAsDartIoFile();
  }

  /// Retrieve the lost [PickedFile] when [selectImage] or [selectVideo] failed because the  MainActivity is destroyed. (Android only)
  ///
  /// Image or video can be lost if the MainActivity is destroyed. And there is no guarantee that the MainActivity is always alive.
  /// Call this method to retrieve the lost data and process the data according to your APP's business logic.
  ///
  /// Returns a [LostData] object if successfully retrieved the lost data. The [LostData] object can represent either a
  /// successful image/video selection, or a failure.
  ///
  /// Calling this on a non-Android platform will throw [UnimplementedError] exception.
  ///
  /// See also:
  /// * [LostData], for what's included in the response.
  /// * [Android Activity Lifecycle](https://developer.android.com/reference/android/app/Activity.html), for more information on MainActivity destruction.
  Future<LostData> getLostData() {
    return platform.retrieveLostData();
  }
}
