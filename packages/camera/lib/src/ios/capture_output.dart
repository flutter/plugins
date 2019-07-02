// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of ios_camera;

enum PixelFormatType { bgra32 }

enum _CaptureOutputClass { captureVideoDataOutput }

abstract class CaptureOutput with NativeMethodCallHandler, CameraMappable {}

class CaptureVideoDataOutput extends CaptureOutput {
  CaptureVideoDataOutput({this.delegate, this.formatType});

  static const _CaptureOutputClass _outputClass =
      _CaptureOutputClass.captureVideoDataOutput;

  final CaptureVideoDataOutputSampleBufferDelegate delegate;
  final PixelFormatType formatType;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': handle,
      'class': _outputClass.toString(),
      'delegate': delegate?.asMap(),
      'formatType': formatType?.toString(),
    };
  }
}

class CaptureVideoDataOutputSampleBufferDelegate
    with CameraMappable, NativeMethodCallHandler {
  CaptureVideoDataOutputSampleBufferDelegate({NativeTexture texture})
      : _texture = texture;

  final NativeTexture _texture;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': handle,
      'nativeTexture': _texture?.asMap(),
    };
  }
}
