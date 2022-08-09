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

    @override
    void getInstance(Result<Long> result) {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
            ProcessCameraProvider.getInstance(???); //TODO(cs): get Context from FlutterActivity

        cameraProviderFuture.addListener(() -> {
            try {
                // Camera provider is now guaranteed to be available
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

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
}