// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of ios_camera;

enum CaptureDeviceType { builtInWideAngleCamera }
enum MediaType { video }
enum CaptureDevicePosition { front, back, unspecified }

class CaptureDiscoverySession {
  CaptureDiscoverySession({
    @required List<CaptureDeviceType> deviceTypes,
    @required this.position,
    this.mediaType,
  })  : deviceTypes =
            List<CaptureDeviceType>.unmodifiable(deviceTypes).toList(),
        assert(deviceTypes != null),
        assert(deviceTypes.isNotEmpty),
        assert(position != null);

  final List<CaptureDeviceType> deviceTypes;
  final MediaType mediaType;
  final CaptureDevicePosition position;

  List<CaptureDevice> _devices;

  Future<List<CaptureDevice>> get devices async {
    if (_devices != null) {
      return Future<List<CaptureDevice>>.value(_devices);
    }

    final List<dynamic> deviceData =
        await CameraChannel.channel.invokeListMethod<dynamic>(
      '$CaptureDiscoverySession#devices',
      <String, dynamic>{
        'deviceTypes': deviceTypes
            .map<String>((CaptureDeviceType type) => type.toString())
            .toList(),
        'mediaType': mediaType?.toString(),
        'position': position.toString(),
      },
    );

    return _devices = List<CaptureDevice>.unmodifiable(deviceData
        .map<CaptureDevice>((dynamic data) => CaptureDevice._fromMap(data))
        .toList());
  }
}
