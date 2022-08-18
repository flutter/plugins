// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraSelectorHostApi;
import java.util.ArrayList;
import java.util.List;

public class CameraSelectorHostApiImpl implements CameraSelectorHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  public CameraSelectorHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public Long requireLensFacing(@NonNull Long instanceId, @NonNull Long lensDirection) {
    CameraSelector cameraSelector =
        (CameraSelector)
            instanceManager.getInstance(
                instanceId); // may be null? // TODO(cs): this is not necessary? remove identifier
    CameraSelector cameraSelectorWithLensSpecified =
        (new CameraSelector.Builder()).requireLensFacing(Math.toIntExact(lensDirection)).build();

    final CameraSelectorFlutterApiImpl cameraInfoFlutterApi =
        new CameraSelectorFlutterApiImpl(binaryMessenger, instanceManager);
    cameraInfoFlutterApi.create(cameraSelectorWithLensSpecified, result -> {});
    Long cameraSelectorWithLensSpecifiedId =
        instanceManager.getIdentifierForStrongReference(cameraSelectorWithLensSpecified);

    return cameraSelectorWithLensSpecifiedId;
  }

  @Override
  public List<Long> filter(
      @NonNull Long instanceId,
      @NonNull List<Long> cameraInfos) { //TODO(cs): change argument to cameraInfosId
    CameraSelector cameraSelector =
        (CameraSelector) instanceManager.getInstance(instanceId); // may be null?
    List<CameraInfo> cameraInfosForFilter = new ArrayList<CameraInfo>();

    for (Long cameraInfoId : cameraInfos) {
      CameraInfo cameraInfo = (CameraInfo) instanceManager.getInstance(cameraInfoId);
      cameraInfosForFilter.add(cameraInfo);
    }

    List<CameraInfo> filteredCameraInfos = cameraSelector.filter(cameraInfosForFilter);
    final CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
    List<Long> filteredCameraInfosIds = new ArrayList<Long>();

    for (CameraInfo cameraInfo : filteredCameraInfos) {
      cameraInfoFlutterApiImpl.create(cameraInfo, result -> {});
      Long cameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
      filteredCameraInfosIds.add(cameraInfoId);
    }

    return filteredCameraInfosIds;
  }
}
