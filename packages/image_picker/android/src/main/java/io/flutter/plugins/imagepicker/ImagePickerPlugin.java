// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import com.esafirm.imagepicker.features.camera.DefaultCameraModule;
import com.esafirm.imagepicker.features.camera.OnImageReadyListener;
import com.esafirm.imagepicker.model.Image;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;
import java.io.IOException;
import java.util.List;

public class ImagePickerPlugin
    implements MethodChannel.MethodCallHandler,
        PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener {
  private static final String CHANNEL = "plugins.flutter.io/image_picker";

  private static final int REQUEST_CODE_PICK = 2342;
  private static final int REQUEST_CODE_CAMERA = 2343;

  private static final int REQUEST_EXTERNAL_STORAGE_PERMISSIONS = 2344;
  private static final int REQUEST_CAMERA_PERMISSIONS = 2345;

  private static final int SOURCE_CAMERA = 0;
  private static final int SOURCE_GALLERY = 1;

  private static final DefaultCameraModule cameraModule = new DefaultCameraModule();

  private final PluginRegistry.Registrar registrar;
  private final ImageResizer imageResizer;
  private final ExifDataCopier exifDataCopier;

  // Pending method call to obtain an image
  private MethodChannel.Result pendingResult;
  private MethodCall methodCall;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    final ImagePickerPlugin instance =
        new ImagePickerPlugin(registrar, new ImageResizer(), new ExifDataCopier());

    registrar.addActivityResultListener(instance);
    registrar.addRequestPermissionsResultListener(instance);

    channel.setMethodCallHandler(instance);
  }

  private ImagePickerPlugin(
      PluginRegistry.Registrar registrar,
      ImageResizer imageResizer,
      ExifDataCopier exifDataCopier) {
    this.registrar = registrar;
    this.imageResizer = imageResizer;
    this.exifDataCopier = exifDataCopier;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (pendingResult != null) {
      result.error("ALREADY_ACTIVE", "Image picker is already active", null);
      return;
    }

    Activity activity = registrar.activity();
    if (activity == null) {
      result.error("no_activity", "image_picker plugin requires a foreground activity.", null);
      return;
    }

    pendingResult = result;
    methodCall = call;

    if (call.method.equals("pickImage")) {
      int imageSource = call.argument("source");

      switch (imageSource) {
        case SOURCE_GALLERY:
          pickImageFromGallery(activity);
          break;
        case SOURCE_CAMERA:
          if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
                  != PackageManager.PERMISSION_GRANTED
              || ContextCompat.checkSelfPermission(
                      activity, Manifest.permission.READ_EXTERNAL_STORAGE)
                  != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                activity,
                new String[] {
                  Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE
                },
                REQUEST_CAMERA_PERMISSIONS);
            break;
          }
          activity.startActivityForResult(
              // TODO: Refactor to use the native camera. After that, remove the
              // com.esafirm.imagepicker depency.
              cameraModule.getCameraIntent(activity), REQUEST_CODE_CAMERA);
          break;
        default:
          throw new IllegalArgumentException("Invalid image source: " + imageSource);
      }
    } else {
      throw new IllegalArgumentException("Unknown method " + call.method);
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_CODE_PICK) {
      if (resultCode == Activity.RESULT_OK && data != null) {
        String path = FileUtils.getPathFromUri(registrar.activity(), data.getData());
        handleResult(path);
        return true;
      } else if (resultCode != Activity.RESULT_CANCELED) {
        pendingResult.error("PICK_ERROR", "Error picking image", null);
      }

      pendingResult = null;
      methodCall = null;
      return true;
    }
    if (requestCode == REQUEST_CODE_CAMERA) {
      if (resultCode == Activity.RESULT_OK) {
        cameraModule.getImage(
            registrar.context(),
            data,
            new OnImageReadyListener() {
              @Override
              public void onImageReady(List<Image> images) {
                handleResult(images.get(0).getPath());
              }
            });
        return true;
      } else if (resultCode != Activity.RESULT_CANCELED) {
        pendingResult.error("PICK_ERROR", "Error taking photo", null);
      }

      pendingResult = null;
      methodCall = null;
      return true;
    }
    return false;
  }

  private void pickImageFromGallery(Activity activity) {
    boolean hasPermission =
        ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE)
            == PackageManager.PERMISSION_GRANTED;

    if (hasPermission) {
      Intent pickImageIntent = new Intent(Intent.ACTION_GET_CONTENT);
      pickImageIntent.setType("image/*");

      activity.startActivityForResult(pickImageIntent, REQUEST_CODE_PICK);
    } else {
      requestReadExternalStoragePermission();
    }
  }

  private void requestReadExternalStoragePermission() {
    ActivityCompat.requestPermissions(
        registrar.activity(),
        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
        REQUEST_EXTERNAL_STORAGE_PERMISSIONS);
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == REQUEST_EXTERNAL_STORAGE_PERMISSIONS
        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      pickImageFromGallery(registrar.activity());
    } else if (requestCode == REQUEST_CAMERA_PERMISSIONS) {
      if (grantResults.length == 2
          && grantResults[0] == PackageManager.PERMISSION_GRANTED
          && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
        Activity activity = registrar.activity();
        if (activity == null) {
          pendingResult.error(
              "no_activity", "image_picker plugin requires a foreground activity.", null);
        }
        activity.startActivityForResult(
            cameraModule.getCameraIntent(activity), REQUEST_CODE_CAMERA);
      } else {
        pendingResult.error(
            "no_permissions", "image_picker plugin requires camera permissions", null);
        pendingResult = null;
        methodCall = null;
      }
      return true;
    }
    return false;
  }

  private void handleResult(String path) {
    if (pendingResult != null) {
      Double maxWidth = methodCall.argument("maxWidth");
      Double maxHeight = methodCall.argument("maxHeight");
      boolean shouldScale = maxWidth != null || maxHeight != null;

      if (!shouldScale) {
        pendingResult.success(path);
      } else {
        try {
          File scaledImage = imageResizer.resizedImage(path, maxWidth, maxHeight);
          exifDataCopier.copyExif(path, scaledImage.getPath());
          pendingResult.success(scaledImage.getPath());
        } catch (IOException e) {
          throw new RuntimeException(e);
        }
      }

      pendingResult = null;
      methodCall = null;
    } else {
      throw new IllegalStateException("Received images from picker that were not requested");
    }
  }
}
