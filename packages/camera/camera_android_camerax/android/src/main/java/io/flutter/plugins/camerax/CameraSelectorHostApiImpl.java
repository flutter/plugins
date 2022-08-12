// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraSelectorHostApiImpl extends CameraSelectorHostApi {
  final InstanceManager instanceManager;

  public CameraSelectorHostApiImpl(
    InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @override
  Long requireLensFacing(@NonNull Long instanceId, @NonNull Long lensDirection) {
    CameraSelector cameraSelector =
      (CameraSelector) instanceManager.getInstance(instanceId);
    CameraSelector cameraSelectorWithLensSpecified =
      cameraSelector.requireLensFacing(lensDirection).build(); //TODO(cs): make sure values align with Dart
    
    // do create mess here
  }

  @override
  List<Long> filter(@NonNull Long instanceId, @NonNull List<Long> cameraInfos) {

  }
}
