// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  private Activity activity;

  public ProcessCameraProviderHostApiImpl(
      BinaryMessenger binaryMessenger,
      InstanceManager instanceManager,
      Activity activity) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.activity = activity;
  }

  // Returns the instance of the ProcessCameraProvider.
  @override
  void getInstance(Result<Long> result) {
    ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
      ProcessCameraProvider.getInstance(activity.getContext());

    cameraProviderFuture.addListener(
      () -> {
        try {
          // Camera provider is now guaranteed to be available
          ProcessCameraProvider processCameraProvider = cameraProviderFuture.get();

          if (!instanceManager.containsInstance(cameraProvider)) {
            // If cameraProvider is already defined, this method will have no effect.
            final ProcessCameraProviderFlutterApiImpl flutterApi =
                ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
            flutterApi.create(processCameraProvider, result -> {});
          }
        } catch (Exception e) {
          result.error(e);
        }
      }
    );
  }

  // Returns cameras available to the ProcessCameraProvider.
  @override
  List<Long> getAvailableCameras(@NonNull Long instanceId) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) instanceManager.getInstance(instancedId); // may return null?

    List<CameraInfo> availableCameras = processCameraProvider.getAvailableCameras();
    List<Long> availableCamerasIds = new List<Long>();
    final CameraInfoFlutterApiImpl cameraInfoFlutterApi =
        CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);

    for (CameraInfo cameraInfo : availableCameras) {
      cameraInfoFlutterApi.create(cameraInfo, result -> {});
      int cameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
      availableCamerasIds.add(cameraInfoId);
    }
    return availableCamerasIds;
  }
}
