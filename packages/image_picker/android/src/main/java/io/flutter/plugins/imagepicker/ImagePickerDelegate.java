// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

public class ImagePickerDelegate
    implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener {
  private static final int REQUEST_CODE_CHOOSE_FROM_GALLERY = 2342;
  private static final int REQUEST_CODE_TAKE_WITH_CAMERA = 2343;
  private static final int REQUEST_IMAGE_PICKER_PERMISSIONS = 2344;

  private final Activity registrar;
  private final ImageResizer imageResizer;
  private final String providerName;

  private Uri pendingCameraImageUri;
  private MethodChannel.Result pendingResult;
  private MethodCall methodCall;
  private ImagePickingOperationType pendingPickImageOperation;

  public static class FileProvider extends android.support.v4.content.FileProvider {}

  private enum ImagePickingOperationType {
    CHOOSE_FROM_GALLERY,
    TAKE_WITH_CAMERA
  }

  public ImagePickerDelegate(Activity registrar, ImageResizer imageResizer) {
    this.registrar = registrar;
    this.imageResizer = imageResizer;
    this.providerName = registrar.getPackageName() + ".flutter.image_provider";
  }

  public void chooseImageFromGallery(MethodCall methodCall, MethodChannel.Result result) {
    setPendingMethodCallAndResult(methodCall, result);

    if (!hasRequiredPermissions()) {
      pendingPickImageOperation = ImagePickingOperationType.CHOOSE_FROM_GALLERY;
      requestPermissions();
      return;
    }

    launchPickImageFromGalleryIntent();
  }

  private boolean hasRequiredPermissions() {
    boolean hasExternalStoragePermission =
        ActivityCompat.checkSelfPermission(registrar, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            == PackageManager.PERMISSION_GRANTED;

    boolean hasCameraPermission =
        ActivityCompat.checkSelfPermission(registrar, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED;

    return hasExternalStoragePermission && hasCameraPermission;
  }

  private void requestPermissions() {
    ActivityCompat.requestPermissions(
        registrar,
        new String[] {Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE},
        REQUEST_IMAGE_PICKER_PERMISSIONS);
  }

  private void launchPickImageFromGalleryIntent() {
    Intent pickImageIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickImageIntent.setType("image/*");

    registrar.startActivityForResult(pickImageIntent, REQUEST_CODE_CHOOSE_FROM_GALLERY);
  }

  public void takeImageWithCamera(MethodCall methodCall, MethodChannel.Result result) {
    setPendingMethodCallAndResult(methodCall, result);

    if (!hasRequiredPermissions()) {
      pendingPickImageOperation = ImagePickingOperationType.TAKE_WITH_CAMERA;
      requestPermissions();
      return;
    }

    launchTakeImageWithCameraIntent();
  }

  private void launchTakeImageWithCameraIntent() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

    if (intent.resolveActivity(registrar.getPackageManager()) != null) {
      File imageFile = createTemporaryWritableImageFile();
      pendingCameraImageUri = Uri.parse("file:" + imageFile.getAbsolutePath());

      Uri imageUri = FileProvider.getUriForFile(registrar, providerName, imageFile);
      intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
      grantUriPermissions(intent, imageUri);

      registrar.startActivityForResult(intent, REQUEST_CODE_TAKE_WITH_CAMERA);
    }
  }

  private File createTemporaryWritableImageFile() {
    String filename = UUID.randomUUID().toString();
    File storageDirectory = registrar.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
    File image;

    try {
      image = File.createTempFile(filename, ".png", storageDirectory);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }

    return image;
  }

  private void grantUriPermissions(Intent intent, Uri imageUri) {
    PackageManager packageManager = registrar.getPackageManager();
    List<ResolveInfo> compatibleActivities =
        packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);

    for (ResolveInfo info : compatibleActivities) {
      registrar.grantUriPermission(
          info.activityInfo.packageName,
          imageUri,
          Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
    }
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == REQUEST_IMAGE_PICKER_PERMISSIONS) {
      boolean bothPermissionsGranted =
          grantResults[0] == PackageManager.PERMISSION_GRANTED
              && grantResults[1] == PackageManager.PERMISSION_GRANTED;

      if (bothPermissionsGranted) {
        executePendingOperation();
      } else {
        pendingResult.error(
            "no_permissions", "image_picker plugin requires camera permissions", null);
        clearMethodCallAndResult();
      }
      return true;
    }
    return false;
  }

  private void executePendingOperation() {
    if (pendingPickImageOperation != null) {
      switch (pendingPickImageOperation) {
        case CHOOSE_FROM_GALLERY:
          launchPickImageFromGalleryIntent();
          break;
        case TAKE_WITH_CAMERA:
          launchTakeImageWithCameraIntent();
          break;
      }

      pendingPickImageOperation = null;
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_CODE_CHOOSE_FROM_GALLERY) {
      return handleChoosePictureResult(resultCode, data);
    } else if (requestCode == REQUEST_CODE_TAKE_WITH_CAMERA) {
      return handleTakePictureResult(resultCode);
    }
    return false;
  }

  private boolean handleChoosePictureResult(int resultCode, Intent data) {
    if (resultCode == Activity.RESULT_OK && data != null) {
      String path = FileUtils.getPathFromUri(registrar, data.getData());
      handleResult(path);
      return true;
    } else if (resultCode != Activity.RESULT_CANCELED) {
      pendingResult.error("PICK_ERROR", "Error picking image", null);
    }

    clearMethodCallAndResult();
    return true;
  }

  private boolean handleTakePictureResult(int resultCode) {
    if (resultCode == Activity.RESULT_OK) {
      MediaScannerConnection.scanFile(
          registrar,
          new String[] {pendingCameraImageUri.getPath()},
          null,
          new MediaScannerConnection.OnScanCompletedListener() {
            @Override
            public void onScanCompleted(String path, Uri uri) {
              handleResult(path);
            }
          });
      return true;
    } else if (resultCode != Activity.RESULT_CANCELED) {
      pendingResult.error("PICK_ERROR", "Error taking photo", null);
      clearMethodCallAndResult();
    }
    return true;
  }

  private void handleResult(String path) {
    if (pendingResult != null) {
      Double maxWidth = methodCall.argument("maxWidth");
      Double maxHeight = methodCall.argument("maxHeight");

      String finalImagePath = imageResizer.resizeImageIfNeeded(path, maxWidth, maxHeight);
      pendingResult.success(finalImagePath);

      clearMethodCallAndResult();
    } else {
      throw new IllegalStateException("Received images from picker that were not requested");
    }
  }

  private void setPendingMethodCallAndResult(MethodCall methodCall, MethodChannel.Result result) {
    if (pendingResult != null) {
      result.error("ALREADY_ACTIVE", "Image picker is already active", null);
      return;
    }

    this.methodCall = methodCall;
    pendingResult = result;
  }

  private void clearMethodCallAndResult() {
    methodCall = null;
    pendingResult = null;
  }
}
