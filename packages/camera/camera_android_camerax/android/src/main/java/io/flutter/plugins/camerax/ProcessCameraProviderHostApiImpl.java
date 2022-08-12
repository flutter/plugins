// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;

    private Activity activity;
    private ProcessCameraProvider provider;

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

        cameraProviderFuture.addListener(() -> {
            try {
                // Camera provider is now guaranteed to be available
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                provider = cameraProvider;

                if (!instanceManager.containsInstance(cameraProvider)) {
                    // If cameraProvider is already defined, this method will have no effect.
                    final ProcessCameraProviderFlutterApiImpl flutterApi =
                        ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
                    flutterApi.create(cameraProvider, result -> {});
                }
            } catch (Exception e) {
                result.error(e);
        }
        });
    }

    @override
    List<CameraInfo> getAvailableCameras() {
      if (provider != null) {
        List<CameraInfo> availableCameras = provider.getAvailableCameras;
        return availableCameras;
      } else {
        // Throw error because provider needs to be instantiated first.
      }
    }
}