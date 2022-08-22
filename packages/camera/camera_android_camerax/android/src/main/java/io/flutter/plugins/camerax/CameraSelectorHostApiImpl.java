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
  public Long requireLensFacing(@NonNull Long lensDirection) {
    CameraSelector cameraSelectorWithLensSpecified =
        (new CameraSelector.Builder()).requireLensFacing(Math.toIntExact(lensDirection)).build();

    final CameraSelectorFlutterApiImpl cameraInfoFlutterApi =
        new CameraSelectorFlutterApiImpl(binaryMessenger, instanceManager);
    long cameraSelectorWithLensSpecifiedId =
        instanceManager.addHostCreatedInstance(cameraSelectorWithLensSpecified);
    cameraInfoFlutterApi.create(cameraSelectorWithLensSpecified, lensDirection, result -> {});

    return cameraSelectorWithLensSpecifiedId;
  }

  @Override
  public List<Long> filter(@NonNull Long instanceId, @NonNull List<Long> cameraInfoIds) {
    CameraSelector cameraSelector = (CameraSelector) instanceManager.getInstance(instanceId);
    List<CameraInfo> cameraInfosForFilter = new ArrayList<CameraInfo>();

    for (Number cameraInfoId1 : cameraInfoIds) {
      Long cameraInfoId = cameraInfoId1.longValue();

      CameraInfo cameraInfo = (CameraInfo) instanceManager.getInstance(cameraInfoId);
      cameraInfosForFilter.add(cameraInfo);
    }

    List<CameraInfo> filteredCameraInfos = cameraSelector.filter(cameraInfosForFilter);
    final CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
    List<Long> filteredCameraInfosIds = new ArrayList<Long>();

    for (CameraInfo cameraInfo : filteredCameraInfos) {
      long cameraInfoId = instanceManager.addHostCreatedInstance(cameraInfo);
      cameraInfoFlutterApiImpl.create(cameraInfo, result -> {});
      filteredCameraInfosIds.add(cameraInfoId);
    }

    return filteredCameraInfosIds;
  }
}
