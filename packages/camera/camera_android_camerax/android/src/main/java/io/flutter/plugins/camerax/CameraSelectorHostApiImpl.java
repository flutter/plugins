// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraSelectorHostApiImpl extends CameraSelectorHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  public CameraSelectorHostApiImpl(
    BinaryMessenger binaryMessenger,
    InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @override
  Long requireLensFacing(@NonNull Long instanceId, @NonNull Long lensDirection) {
    CameraSelector cameraSelector =
      (CameraSelector) instanceManager.getInstance(instanceId); // may be null?
    CameraSelector cameraSelectorWithLensSpecified =
      cameraSelector.requireLensFacing(lensDirection).build(); //TODO(cs): make sure values align with Dart
    
    final CameraSelectorFlutterApi cameraInfoFlutterApi =
        CameraSelectorFlutterApi(binaryMessenger, instanceManager);
    cameraInfoFlutterApi.create(cameraSelectorWithLensSpecified, result -> {});
    int cameraSelectorWithLensSpecifiedId = instanceManager.getIdentifierForStrongReference(cameraSelectorWithLensSpecified);

    return cameraSelectorWithLensSpecifiedId;
  }

  @override
  List<Long> filter(@NonNull Long instanceId, @NonNull List<Long> cameraInfos) { //TODO(cs): change argument to cameraInfosId
    CameraSelector cameraSelector =
      (CameraSelector) instanceManager.getInstance(instanceId); // may be null?
    List<CameraInfo> cameraInfosForFilter = new List<CameraInfo>();

    for (int cameraInfoId : cameraInfos) {
      CameraInfo cameraInfo = (CameraInfo) instanceManager.getInstance(cameraInfoId);
      cameraInfosForFilter.add(cameraInfosForFilter);
    }
 
    List<CameraInfo> filteredCameraInfos = cameraSelector.filter(cameraInfosForFilter);
    final CameraSelectorFlutterApi cameraInfoFlutterApi =
      CameraSelectorFlutterApi(binaryMessenger, instanceManager);
    List<Long> filteredCameraInfosIds = new List<Long>();

    for (CameraInfo cameraInfo : filteredCameraInfos) {
      cameraInfoFlutterApi.create(cameraInfo, result -> {});
      int cameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
      filteredCameraInfosIds.add(cameraInfoId);
    }

    return filteredCameraInfosIds;
  }
}
