// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// The Windows implementation of [ImagePickerPlatform].
///
/// This class implements the `package:image_picker` functionality for Windows.
class ImagePickerWindowsPlugin extends ImagePickerPlatform {
  /// A constructor that allows tests to override the function that creates file inputs.
  ImagePickerWindowsPlugin();

  List<String> _imageFormats = ['jpg', 'jpeg', 'png', 'bmp'];
  List<String> _videoFormats = ['mov', 'wmv', 'mkv', 'mp4'];

  /// Registers this class as the default instance of [ImagePickerPlatform].
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerWindowsPlugin();
  }

  /// Returns a [PickedFile] with the image that was picked.
  ///
  /// The `source` argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// Note that the `maxWidth`, `maxHeight` and `imageQuality` arguments are not supported on the Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// If no images were picked, the return value is null.
  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final typeGroup = XTypeGroup(label: 'images', extensions: _imageFormats);
    final file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      return PickedFile(file.path);
    }
    return null;
  }

  /// Returns a [PickedFile] containing the video that was picked.
  ///
  /// The [source] argument controls where the video comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// Note that the `maxDuration` argument is not supported on the Windows. If the argument is supplied, it'll be silently ignored by the Windows version of the plugin.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// If no images were picked, the return value is null.
  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final typeGroup = XTypeGroup(label: 'videos', extensions: _videoFormats);
    final file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      return PickedFile(file.path);
    }
    return null;
  }

  /// Returns an [XFile] with the image that was picked.
  ///
  /// The `source` argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// Note that the `maxWidth`, `maxHeight` and `imageQuality` arguments are not supported on the Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// If no images were picked, the return value is null.
  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final typeGroup = XTypeGroup(label: 'images', extensions: _imageFormats);
    final file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: [typeGroup]);
    return file;
  }

  /// Returns an [XFile] containing the video that was picked.
  ///
  /// The [source] argument controls where the video comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// Note that the `maxDuration` argument is not supported on the Windows. If the argument is supplied, it'll be silently ignored by the Windows version of the plugin.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// If no images were picked, the return value is null.
  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final typeGroup = XTypeGroup(label: 'videos', extensions: _videoFormats);
    final file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: [typeGroup]);
    return file;
  }

  /// Injects a file input, and returns a list of XFile that the user selected locally.
  @override
  Future<List<XFile>> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final typeGroup = XTypeGroup(label: 'images', extensions: _imageFormats);
    final files = await FileSelectorPlatform.instance
        .openFiles(acceptedTypeGroups: [typeGroup]);
    return files;
  }
}
