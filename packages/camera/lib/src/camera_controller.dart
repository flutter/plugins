// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

import '../android_camera.dart';
import '../ios_camera.dart';
import '../support_android_camera.dart';
import 'android_camera_configurator.dart';
import 'common/camera_abstraction.dart';
import 'ios_camera_configuator.dart';
import 'support_android_camera_configurator.dart';

class CameraController {
  factory CameraController({@required CameraDescription description}) {
    assert(description != null);
    return CameraController._(
      description: description,
      configurator: _createDefaultConfigurator(description),
      api: _getCameraApi(description),
    );
  }

  CameraController._({
    @required this.description,
    @required this.configurator,
    @required this.api,
  })  : assert(description != null),
        assert(configurator != null),
        assert(api != null);

  factory CameraController.customConfigurator({
    @required CameraDescription description,
    @required CameraConfigurator configurator,
  }) {
    return CameraController._(
      description: description,
      configurator: configurator,
      api: _getCameraApi(description),
    );
  }

  final CameraDescription description;
  final CameraConfigurator configurator;
  final CameraApi api;

  static Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> devices = <CameraDescription>[];

    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo info = await infoPlugin.androidInfo;
      if (info.version.sdkInt < 21) {
        final int numCameras = await SupportAndroidCamera.getNumberOfCameras();
        for (int i = 0; i < numCameras; i++) {
          devices.add(await SupportAndroidCamera.getCameraInfo(i));
        }
      } else {
        final List<String> cameraIds =
            await CameraManager.instance.getCameraIdList();
        for (String id in cameraIds) {
          devices.add(
            await CameraManager.instance.getCameraCharacteristics(id),
          );
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IosDeviceInfo info = await infoPlugin.iosInfo;
      final double version = double.tryParse(info.systemVersion) ?? 8.0;
      if (version >= 10) {
        final CaptureDiscoverySession session = CaptureDiscoverySession(
          deviceTypes: <CaptureDeviceType>[
            CaptureDeviceType.builtInWideAngleCamera
          ],
          position: CaptureDevicePosition.unspecified,
          mediaType: MediaType.video,
        );

        devices.addAll(await session.devices);
      } else {
        devices.addAll(await CaptureDevice.getDevices(MediaType.video));
      }
    } else {
      throw UnimplementedError('$defaultTargetPlatform not supported');
    }

    return devices;
  }

  Future<void> start() => configurator.start();
  Future<void> stop() => configurator.stop();
  Future<void> dispose() => configurator.dispose();

  static CameraConfigurator _createDefaultConfigurator(
    CameraDescription description,
  ) {
    final CameraApi api = _getCameraApi(description);
    switch (api) {
      case CameraApi.android:
        return AndroidCameraConfigurator(description);
      case CameraApi.iOS:
        return IOSCameraConfigurator(description);
      case CameraApi.supportAndroid:
        return SupportAndroidCameraConfigurator(description);
    }

    return null;
  }

  static CameraApi _getCameraApi(CameraDescription description) {
    if (description is CameraInfo) {
      return CameraApi.supportAndroid;
    } else if (description is CameraCharacteristics) {
      return CameraApi.android;
    } else if (description is CaptureDevice) {
      return CameraApi.iOS;
    }

    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
  }
}
