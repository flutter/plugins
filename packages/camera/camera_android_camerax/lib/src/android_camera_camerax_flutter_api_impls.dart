// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'camera.dart';
import 'camera_control.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camerax_library.pigeon.dart';
import 'java_object.dart';
import 'preview.dart';
import 'process_camera_provider.dart';

/// Handles initialization of Flutter APIs for the Android CameraX library.
class AndroidCameraXCameraFlutterApis {
  /// Creates a [AndroidCameraXCameraFlutterApis].
  AndroidCameraXCameraFlutterApis({
    JavaObjectFlutterApiImpl? javaObjectFlutterApi,
    CameraInfoFlutterApiImpl? cameraInfoFlutterApi,
    CameraSelectorFlutterApiImpl? cameraSelectorFlutterApi,
    ProcessCameraProviderFlutterApiImpl? processCameraProviderFlutterApi,
    PreviewFlutterApiImpl? previewFlutterApi,
    CameraFlutterApiImpl? cameraFlutterApi,
    CameraControlFlutterApiImpl? cameraControlFlutterApi,
  }) {
    this.javaObjectFlutterApi =
        javaObjectFlutterApi ?? JavaObjectFlutterApiImpl();
    this.cameraInfoFlutterApi =
        cameraInfoFlutterApi ?? CameraInfoFlutterApiImpl();
    this.cameraSelectorFlutterApi =
        cameraSelectorFlutterApi ?? CameraSelectorFlutterApiImpl();
    this.processCameraProviderFlutterApi = processCameraProviderFlutterApi ??
        ProcessCameraProviderFlutterApiImpl();
    this.previewFlutterApi = previewFlutterApi ??
        PreviewFlutterApiImpl();
    this.cameraFlutterApi = cameraFlutterApi ??
        CameraFlutterApiImpl();
    this.cameraControlFlutterApi = cameraControlFlutterApi ??
        CameraControlFlutterApiImpl();
  }

  static bool _haveBeenSetUp = false;

  /// Mutable instance containing all Flutter Apis for Android CameraX Camera.
  ///
  /// This should only be changed for testing purposes.
  static AndroidCameraXCameraFlutterApis instance =
      AndroidCameraXCameraFlutterApis();

  /// Handles callbacks methods for the native Java Object class.
  late final JavaObjectFlutterApi javaObjectFlutterApi;

  /// Flutter Api for [CameraInfo].
  late final CameraInfoFlutterApiImpl cameraInfoFlutterApi;

  /// Flutter Api for [CameraSelector].
  late final CameraSelectorFlutterApiImpl cameraSelectorFlutterApi;

  /// Flutter Api for [ProcessCameraProvider].
  late final ProcessCameraProviderFlutterApiImpl
      processCameraProviderFlutterApi;

  /// Flutter Api for [Preview].
  late final PreviewFlutterApiImpl previewFlutterApi;

  /// Flutter Api for [Camera].
  late final CameraFlutterApiImpl cameraFlutterApi;

  /// Flutter Api for [CameraControl].
  late final CameraControlFlutterApiImpl cameraControlFlutterApi;

  /// Ensures all the Flutter APIs have been setup to receive calls from native code.
  void ensureSetUp() {
    if (!_haveBeenSetUp) {
      JavaObjectFlutterApi.setup(javaObjectFlutterApi);
      CameraInfoFlutterApi.setup(cameraInfoFlutterApi);
      CameraSelectorFlutterApi.setup(cameraSelectorFlutterApi);
      ProcessCameraProviderFlutterApi.setup(processCameraProviderFlutterApi);
      PreviewFlutterApi.setup(previewFlutterApi);
      CameraFlutterApi.setup(cameraFlutterApi);
      CameraControlFlutterApi.setup(cameraControlFlutterApi);
      _haveBeenSetUp = true;
    }
  }
}
