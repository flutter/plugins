// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.Preview;
import androidx.camera.core.UseCase;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ProcessCameraProviderHostApi;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import androidx.camera.core.UseCaseGroup;
import io.flutter.plugins.camerax.CameraPermissions.PermissionsRegistry;

public class ProcessCameraProviderHostApiImpl implements ProcessCameraProviderHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  private Context context;
  private LifecycleOwner lifecycleOwner;
  private PermissionsRegistry permissionsRegistry;

  public ProcessCameraProviderHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager, Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
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

  public void setLifecycleOwner(LifecycleOwner lifecycleOwner) {
    this.lifecycleOwner = lifecycleOwner;
  }

  public void setPermissionsRegistry(PermissionsRegistry permissionsRegistry) {
    this.permissionsRegistry = permissionsRegistry;
  }

  /**
   * Returns the instance of the ProcessCameraProvider to manage the lifecycle of the camera for the
   * current {@code Context}.
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

            if (!instanceManager.containsInstance(processCameraProvider)) {
              final ProcessCameraProviderFlutterApiImpl flutterApi =
                  new ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
              flutterApi.create(processCameraProvider, reply -> {});
            }
            result.success(instanceManager.getIdentifierForStrongReference(processCameraProvider));
          } catch (Exception e) {
            result.error(e);
          }
        },
        ContextCompat.getMainExecutor(context));
  }

  /** Returns cameras available to the ProcessCameraProvider. */
  @Override
  public List<Long> getAvailableCameraInfos(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) instanceManager.getInstance(identifier);

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

  /** Binds specified @code UseCase}s to the lifecycle of the @code LifecycleOwner}
   * that corresponds to this instance.
   */
  @Override
  public Long bindToLifecycle(@NonNull Long identifier, @NonNull Long cameraSelectorIdentifier, @NonNull List<Long> useCaseIds) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) instanceManager.getInstance(identifier);
    CameraSelector cameraSelector =
        (CameraSelector) instanceManager.getInstance(cameraSelectorIdentifier);
    UseCase[] useCases = new UseCase[useCaseIds.size()];
    for (int i = 0; i < useCaseIds.size(); i++) {
      useCases[i] = (Preview) instanceManager.getInstance(((Number) useCaseIds.get(i)).longValue());
    }

    // For testing purposes only
    Preview preview = new Preview.Builder().build();

    if (lifecycleOwner != null) {
      CameraPermissions cameraPermissions = new CameraPermissions();
      cameraPermissions.requestPermissions(
        (Activity) lifecycleOwner,
        permissionsRegistry,
        true,
        (String errCode, String errDesc) -> {});

      Camera camera = processCameraProvider.bindToLifecycle((LifecycleOwner) lifecycleOwner, cameraSelector, useCases); // the problem is that I'm casting them to use cases and then things are getting confused...

      final CameraFlutterApiImpl camraFlutterApi =
          new CameraFlutterApiImpl(binaryMessenger, instanceManager);
      camraFlutterApi.create(camera, result -> {});
      
      return instanceManager.getIdentifierForStrongReference(camera);
    } else {
      return null; // error
    }

  }

  @Override
  public void unbind(@NonNull Long identifier, @NonNull List<Long> useCaseIds) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) instanceManager.getInstance(identifier);
    UseCase[] useCases = new UseCase[useCaseIds.size()];
    for (int i = 0; i < useCaseIds.size(); i++) {
      useCases[i] = (Preview) instanceManager.getInstance(((Number) useCaseIds.get(i)).longValue());
    }
    
    processCameraProvider.unbind(useCases);
  }

  @Override
  public void unbindAll(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
      (ProcessCameraProvider) instanceManager.getInstance(identifier);
    processCameraProvider.unbindAll(); 
  }
}
