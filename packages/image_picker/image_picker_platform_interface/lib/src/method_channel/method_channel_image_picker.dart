// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_platform_interface/src/types/picked_image.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final MethodChannel _channel = MethodChannel('plugins.flutter.io/image_picker');

/// An implementation of [ImagePickerPlatform] that uses method channels.
class MethodChannelImagePicker extends ImagePickerPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<PickedImage> pickImage({
    @required ImageSource source,
    double maxWidth,
    double maxHeight,
    int imageQuality,
    bool createThumbnail = false,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    var paths = await _pickImagePaths(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      createThumbnail: createThumbnail,
      preferredCameraDevice: preferredCameraDevice,
    );
    return paths != null
        ? PickedImage(
            paths['image'],
            thumbnailPath: paths['thumbnail'],
          )
        : null;
  }

  @override
  Future<String> pickImagePath({
    @required ImageSource source,
    double maxWidth,
    double maxHeight,
    int imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    var paths = await _pickImagePaths(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
      createThumbnail: false,
    );
    return paths['image'];
  }

  Future<Map<String, String>> _pickImagePaths({
    @required ImageSource source,
    double maxWidth,
    double maxHeight,
    int imageQuality,
    bool createThumbnail,
    CameraDevice preferredCameraDevice,
  }) async {
    assert(source != null);
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }

    return _channel.invokeMapMethod<String, String>(
      'pickImage',
      <String, dynamic>{
        'source': source.index,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
        'createThumbnail': createThumbnail,
        'cameraDevice': preferredCameraDevice.index
      },
    );
  }

  @override
  Future<PickedFile> pickVideo({
    @required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration maxDuration,
  }) async {
    String path = await pickVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  @override
  Future<String> pickVideoPath({
    @required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration maxDuration,
  }) {
    assert(source != null);
    return _channel.invokeMethod<String>(
      'pickVideo',
      <String, dynamic>{
        'source': source.index,
        'maxDuration': maxDuration?.inSeconds,
        'cameraDevice': preferredCameraDevice.index
      },
    );
  }

  @override
  Future<LostData> retrieveLostData() async {
    final Map<String, dynamic> result =
        await _channel.invokeMapMethod<String, dynamic>('retrieve');

    if (result == null) {
      return LostData.empty();
    }

    assert(result.containsKey('path') ^ result.containsKey('errorCode'));

    final String type = result['type'];
    assert(type == kTypeImage || type == kTypeVideo);

    RetrieveType retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    }

    PlatformException exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode'], message: result['errorMessage']);
    }

    final String path = result['path'];

    return LostData(
      file: path != null ? PickedFile(path) : null,
      exception: exception,
      type: retrieveType,
    );
  }

  @override
  // ignore: deprecated_member_use_from_same_package
  Future<LostDataResponse> retrieveLostDataAsDartIoFile() async {
    final Map<String, dynamic> result =
        await _channel.invokeMapMethod<String, dynamic>('retrieve');
    if (result == null) {
      // ignore: deprecated_member_use_from_same_package
      return LostDataResponse.empty();
    }
    assert(result.containsKey('path') ^ result.containsKey('errorCode'));

    final String type = result['type'];
    assert(type == kTypeImage || type == kTypeVideo);

    RetrieveType retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    }

    PlatformException exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode'], message: result['errorMessage']);
    }

    final String path = result['path'];

    // ignore: deprecated_member_use_from_same_package
    return LostDataResponse(
        file: path == null ? null : File(path),
        exception: exception,
        type: retrieveType);
  }
}
