// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraSelectorHostApi;
import java.util.ArrayList;
import java.util.List;

public class CameraSelectorHostApiImpl implements CameraSelectorHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public CameraSelectorHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public void create(@NonNull Long identifier, Long lensFacing) {
    CameraSelector.Builder cameraSelectorBuilder = cameraXProxy.createCameraSelectorBuilder();
    CameraSelector cameraSelector;

    if (lensFacing != null) {
      cameraSelector = cameraSelectorBuilder.requireLensFacing(Math.toIntExact(lensFacing)).build();
    } else {
      cameraSelector = cameraSelectorBuilder.build();
    }

    instanceManager.addDartCreatedInstance(cameraSelector, identifier);
  }

  @Override
  public List<Long> filter(@NonNull Long identifier, @NonNull List<Long> cameraInfoIds) {
    CameraSelector cameraSelector = (CameraSelector) instanceManager.getInstance(identifier);
    List<CameraInfo> cameraInfosForFilter = new ArrayList<CameraInfo>();

    for (Number cameraInfoAsNumber : cameraInfoIds) {
      Long cameraInfoId = cameraInfoAsNumber.longValue();

      CameraInfo cameraInfo = (CameraInfo) instanceManager.getInstance(cameraInfoId);
      cameraInfosForFilter.add(cameraInfo);
    }

    List<CameraInfo> filteredCameraInfos = cameraSelector.filter(cameraInfosForFilter);
    final CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
    List<Long> filteredCameraInfosIds = new ArrayList<Long>();

    for (CameraInfo cameraInfo : filteredCameraInfos) {
      cameraInfoFlutterApiImpl.create(cameraInfo, result -> {});
      Long filteredCameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
      filteredCameraInfosIds.add(filteredCameraInfoId);
    }

    return filteredCameraInfosIds;
  }
}
