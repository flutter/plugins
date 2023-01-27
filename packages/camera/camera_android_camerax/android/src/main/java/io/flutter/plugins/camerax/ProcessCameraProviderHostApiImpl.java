// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.UseCase;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ProcessCameraProviderHostApi;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class ProcessCameraProviderHostApiImpl implements ProcessCameraProviderHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  private Context context;
  private LifecycleOwner lifecycleOwner;

  public ProcessCameraProviderHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager, Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
  }

  public void setLifecycleOwner(LifecycleOwner lifecycleOwner) {
    this.lifecycleOwner = lifecycleOwner;
  }

  /**
   * Sets the context that the {@code ProcessCameraProvider} will use to attach the lifecycle of the
   * camera to.
   *
   * <p>If using the camera plugin in an add-to-app context, ensure that a new instance of the
   * {@code ProcessCameraProvider} is fetched via {@code #getInstance} anytime the context changes.
   */
  public void setContext(Context context) {
    this.context = context;
  }

  /**
   * Returns the instance of the {@code ProcessCameraProvider} to manage the lifecycle of the camera
   * for the current {@code Context}.
   */
  @Override
  public void getInstance(GeneratedCameraXLibrary.Result<Long> result) {
    ListenableFuture<ProcessCameraProvider> processCameraProviderFuture =
        ProcessCameraProvider.getInstance(context);

    processCameraProviderFuture.addListener(
        () -> {
          try {
            // Camera provider is now guaranteed to be available.
            ProcessCameraProvider processCameraProvider = processCameraProviderFuture.get();

            final ProcessCameraProviderFlutterApiImpl flutterApi =
                new ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
            flutterApi.create(processCameraProvider, reply -> {});
            result.success(instanceManager.getIdentifierForStrongReference(processCameraProvider));
          } catch (Exception e) {
            result.error(e);
          }
        },
        ContextCompat.getMainExecutor(context));
  }

  /** Returns cameras available to the {@code ProcessCameraProvider}. */
  @Override
  public List<Long> getAvailableCameraInfos(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));

    List<CameraInfo> availableCameras = processCameraProvider.getAvailableCameraInfos();
    List<Long> availableCamerasIds = new ArrayList<Long>();
    final CameraInfoFlutterApiImpl cameraInfoFlutterApi =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);

    for (CameraInfo cameraInfo : availableCameras) {
      cameraInfoFlutterApi.create(cameraInfo, result -> {});
      availableCamerasIds.add(instanceManager.getIdentifierForStrongReference(cameraInfo));
    }
    return availableCamerasIds;
  }

  /**
   * Binds specified {@code UseCase}s to the lifecycle of the {@code LifecycleOwner} that
   * corresponds to this instance and returns the instance of the {@code Camera} whose lifecycle
   * that {@code LifecycleOwner} reflects.
   */
  @Override
  public Long bindToLifecycle(
      @NonNull Long identifier,
      @NonNull Long cameraSelectorIdentifier,
      @NonNull List<Long> useCaseIds) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    CameraSelector cameraSelector =
        (CameraSelector)
            Objects.requireNonNull(instanceManager.getInstance(cameraSelectorIdentifier));
    UseCase[] useCases = new UseCase[useCaseIds.size()];
    for (int i = 0; i < useCaseIds.size(); i++) {
      useCases[i] =
          (UseCase)
              Objects.requireNonNull(
                  instanceManager.getInstance(((Number) useCaseIds.get(i)).longValue()));
    }

    Camera camera =
        processCameraProvider.bindToLifecycle(
            (LifecycleOwner) lifecycleOwner, cameraSelector, useCases);

    final CameraFlutterApiImpl cameraFlutterApi =
        new CameraFlutterApiImpl(binaryMessenger, instanceManager);
    cameraFlutterApi.create(camera, result -> {});

    return instanceManager.getIdentifierForStrongReference(camera);
  }

  @Override
  public void unbind(@NonNull Long identifier, @NonNull List<Long> useCaseIds) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    UseCase[] useCases = new UseCase[useCaseIds.size()];
    for (int i = 0; i < useCaseIds.size(); i++) {
      useCases[i] =
          (UseCase)
              Objects.requireNonNull(
                  instanceManager.getInstance(((Number) useCaseIds.get(i)).longValue()));
    }
    processCameraProvider.unbind(useCases);
  }

  @Override
  public void unbindAll(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    processCameraProvider.unbindAll();
  }
}
