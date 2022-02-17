// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// The Windows implementation of [ImagePickerPlatform].
///
/// This class implements the `package:image_picker` functionality for Windows.
class ImagePickerWindows extends ImagePickerPlatform {
  /// Constructs a ImagePickerWindows.
  ImagePickerWindows();

  final List<String> _imageFormats = <String>[
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
  final List<String> _videoFormats = <String>[
    'mov',
    'wmv',
    'mkv',
    'mp4',
    'webm',
    'avi',
    'mpeg',
    'mpg'
  ];

  /// Registers this class as the default instance of [ImagePickerPlatform].
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerWindows();
  }

  // Note that the `maxWidth`, `maxHeight` and `imageQuality` arguments are not supported on the Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
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

  // Note that the `source`, `preferredCameraDevice`, and `maxDuration` arguments are not supported on Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
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

  // Note that the `source`, `maxWidth`, `maxHeight`, `imageQuality`, and `preferredCameraDevice` arguments are not supported on Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final XTypeGroup typeGroup =
        XTypeGroup(label: 'images', extensions: _imageFormats);
    final XFile? file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return file;
  }

  // Note that the `source`, `preferredCameraDevice`, and `maxDuration` arguments are not supported on Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final XTypeGroup typeGroup =
        XTypeGroup(label: 'videos', extensions: _videoFormats);
    final XFile? file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return file;
  }

  // Note that the `maxWidth`, `maxHeight`, and `imageQuality` arguments are not supported on Windows. If any of these arguments is supplied, it'll be silently ignored by the Windows version of the plugin.
  @override
  Future<List<XFile>> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XTypeGroup typeGroup =
        XTypeGroup(label: 'images', extensions: _imageFormats);
    final List<XFile> files = await FileSelectorPlatform.instance
        .openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return files;
  }
}
