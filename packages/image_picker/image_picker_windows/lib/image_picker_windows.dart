// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// The Windows implementation of [ImagePickerPlatform].
///
/// This class implements the `package:image_picker` functionality for
/// Windows.
class ImagePickerWindows extends ImagePickerPlatform {
  /// Constructs a ImagePickerWindows.
  ImagePickerWindows();

  /// List of image extensions used when picking images
  @visibleForTesting
  static const List<String> imageFormats = <String>[
    'jpg',
    'jpeg',
    'png',
    'bmp',
    'webp',
    'gif',
    'tif',
    'tiff',
    'apng'
  ];

  /// List of video extensions used when picking videos
  @visibleForTesting
  static const List<String> videoFormats = <String>[
    'mov',
    'wmv',
    'mkv',
    'mp4',
    'webm',
    'avi',
    'mpeg',
    'mpg'
  ];

  /// The file selector used to prompt the user to select images or videos.
  @visibleForTesting
  static FileSelectorPlatform fileSelector = FileSelectorWindows();

  /// Registers this class as the default instance of [ImagePickerPlatform].
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerWindows();
  }

  // `maxWidth`, `maxHeight`, `imageQuality` and `preferredCameraDevice`
  // arguments are not supported on Windows. If any of these arguments
  // is supplied, it'll be silently ignored  by the Windows version of
  // the plugin. `source` is not implemented for `ImageSource.camera`
  // and will throw an exception.
  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final XFile? file = await getImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice);
    if (file != null) {
      return PickedFile(file.path);
    }
    return null;
  }

  // `preferredCameraDevice` and `maxDuration` arguments are not
  // supported on Windows. If any of these arguments is supplied,
  // it'll be silently ignored by the Windows version of the plugin.
  // `source` is not implemented for `ImageSource.camera` and will
  // throw an exception.
  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final XFile? file = await getVideo(
        source: source,
        preferredCameraDevice: preferredCameraDevice,
        maxDuration: maxDuration);
    if (file != null) {
      return PickedFile(file.path);
    }
    return null;
  }

  // `maxWidth`, `maxHeight`, `imageQuality`, and `preferredCameraDevice`
  // arguments are not supported on Windows. If any of these arguments
  // is supplied, it'll be silently ignored by the Windows version
  // of the plugin. `source` is not implemented for `ImageSource.camera`
  // and will throw an exception.
  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (source != ImageSource.gallery) {
      // TODO(azchohfi): Support ImageSource.camera.
      //                 See https://github.com/flutter/flutter/issues/102115
      throw UnimplementedError(
          'ImageSource.gallery is currently the only supported source on Windows');
    }
    final XTypeGroup typeGroup =
        XTypeGroup(label: 'images', extensions: imageFormats);
    final XFile? file = await fileSelector
        .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return file;
  }

  // `preferredCameraDevice` and `maxDuration` arguments are not
  // supported on Windows. If any of these arguments is supplied,
  // it'll be silently ignored by the Windows version of the plugin.
  // `source` is not implemented for `ImageSource.camera` and will
  // throw an exception.
  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    if (source != ImageSource.gallery) {
      // TODO(azchohfi): Support ImageSource.camera.
      //                 See https://github.com/flutter/flutter/issues/102115
      throw UnimplementedError(
          'ImageSource.gallery is currently the only supported source on Windows');
    }
    final XTypeGroup typeGroup =
        XTypeGroup(label: 'videos', extensions: videoFormats);
    final XFile? file = await fileSelector
        .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return file;
  }

  // `maxWidth`, `maxHeight`, and `imageQuality` arguments are not
  // supported on Windows. If any of these arguments is supplied,
  // it'll be silently ignored by the Windows version of the plugin.
  @override
  Future<List<XFile>> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XTypeGroup typeGroup =
        XTypeGroup(label: 'images', extensions: imageFormats);
    final List<XFile> files = await fileSelector
        .openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return files;
  }
}
