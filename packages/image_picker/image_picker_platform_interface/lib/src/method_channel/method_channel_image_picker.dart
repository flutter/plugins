// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/image_picker');

/// An implementation of [ImagePickerPlatform] that uses method channels.
class MethodChannelImagePicker extends ImagePickerPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final String? path = await _getImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  @override
  Future<List<PickedFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final List<dynamic>? paths = await _getMultiImagePath(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (paths == null) {
      return null;
    }

    return paths.map((dynamic path) => PickedFile(path as String)).toList();
  }

  Future<List<dynamic>?> _getMultiImagePath({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
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

    return _channel.invokeMethod<List<dynamic>?>(
      'pickMultiImage',
      <String, dynamic>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
      },
    );
  }

  Future<String?> _getImagePath({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
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

    return _channel.invokeMethod<String>(
      'pickImage',
      <String, dynamic>{
        'source': source.index,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
        'cameraDevice': preferredCameraDevice.index,
        'requestFullMetadata': requestFullMetadata,
      },
    );
  }

  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final String? path = await _getVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  Future<String?> _getVideoPath({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
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
    final Map<String, dynamic>? result =
        await _channel.invokeMapMethod<String, dynamic>('retrieve');

    if (result == null) {
      return LostData.empty();
    }

    assert(result.containsKey('path') != result.containsKey('errorCode'));

    final String? type = result['type'] as String?;
    assert(type == kTypeImage || type == kTypeVideo);

    RetrieveType? retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    }

    PlatformException? exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode']! as String,
          message: result['errorMessage'] as String?);
    }

    final String? path = result['path'] as String?;

    return LostData(
      file: path != null ? PickedFile(path) : null,
      exception: exception,
      type: retrieveType,
    );
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final String? path = await _getImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final String? path = await _getImagePath(
      source: source,
      maxHeight: options.maxHeight,
      maxWidth: options.maxWidth,
      imageQuality: options.imageQuality,
      preferredCameraDevice: options.preferredCameraDevice,
      requestFullMetadata: options.requestFullMetadata,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<List<XFile>?> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final List<dynamic>? paths = await _getMultiImagePath(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (paths == null) {
      return null;
    }

    return paths.map((dynamic path) => XFile(path as String)).toList();
  }

  @override
  Future<List<XFile>?> getMedia({
    MediaSelectionOptions? options,
  }) async {
    options ??= MediaSelectionOptions();
    final int? imageQuality = options.imageAdjustmentOptions.quality;
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }

    final double? maxImageWidth = options.imageAdjustmentOptions.maxWidth;
    if (maxImageWidth != null && maxImageWidth < 0) {
      throw ArgumentError.value(
          maxImageWidth, 'maxImageWidth', 'cannot be negative');
    }

    final double? maxImageHeight = options.imageAdjustmentOptions.maxHeight;
    if (maxImageHeight != null && maxImageHeight < 0) {
      throw ArgumentError.value(
          maxImageHeight, 'maxImageHeight', 'cannot be negative');
    }

    final Map<String, dynamic> args = <String, dynamic>{
      'types': options.types.map(serializeMediaSelectionType).toList(),
      'maxImageWidth': maxImageWidth,
      'maxImageHeight': maxImageHeight,
      'imageQuality': imageQuality,
      'allowMultiple': options.allowMultiple,
    };
    List<String>? paths;
    if (options.allowMultiple) {
      paths = await _channel
          .invokeMethod<List<dynamic>?>(
            'pickMedia',
            args,
          )
          .then((List<dynamic>? paths) =>
              paths?.map((dynamic path) => path as String).toList());
    } else {
      paths = await _channel
          .invokeMethod<String>(
            'pickMedia',
            args,
          )
          .then((String? path) => path != null ? <String>[path] : null);
    }

    return paths?.map((String path) => XFile(path)).toList();
  }

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final String? path = await _getVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<LostDataResponse> getLostData() async {
    List<XFile>? pickedFileList;

    final Map<String, dynamic>? result =
        await _channel.invokeMapMethod<String, dynamic>('retrieve');

    if (result == null) {
      return LostDataResponse.empty();
    }

    assert(result.containsKey('path') != result.containsKey('errorCode'));

    final String? type = result['type'] as String?;
    assert(
      type == kTypeImage || type == kTypeVideo || type == kTypeMedia,
    );

    RetrieveType? retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    } else if (type == kTypeMedia) {
      retrieveType = RetrieveType.media;
    }

    PlatformException? exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode']! as String,
          message: result['errorMessage'] as String?);
    }

    final String? path = result['path'] as String?;

    final List<String>? pathList =
        (result['pathList'] as List<dynamic>?)?.cast<String>();
    if (pathList != null) {
      pickedFileList = <XFile>[];
      for (final String path in pathList) {
        pickedFileList.add(XFile(path));
      }
    }

    return LostDataResponse(
      file: path != null ? XFile(path) : null,
      exception: exception,
      type: retrieveType,
      files: pickedFileList,
    );
  }
}

/// Serializes a [MediaSelectionType] value into a String value.
String serializeMediaSelectionType(MediaSelectionType type) {
  switch (type) {
    case MediaSelectionType.image:
      return 'image';
    case MediaSelectionType.video:
      return 'video';
  }
}
