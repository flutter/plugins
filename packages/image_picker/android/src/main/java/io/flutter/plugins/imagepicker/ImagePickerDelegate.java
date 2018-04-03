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

  private static final int REQUEST_EXTERNAL_STORAGE_PERMISSION = 2344;
  private static final int REQUEST_CAMERA_PERMISSION = 2345;

  private final Activity activity;
  private final File externalFilesDirectory;
  private final ImageResizer imageResizer;
  private final String providerName;

  private Uri pendingCameraImageUri;
  private MethodChannel.Result pendingResult;
  private MethodCall methodCall;

  public static class FileProvider extends android.support.v4.content.FileProvider {}

  public ImagePickerDelegate(Activity activity, File externalFilesDirectory, ImageResizer imageResizer) {
    this.activity = activity;
    this.externalFilesDirectory = externalFilesDirectory;
    this.imageResizer = imageResizer;
    this.providerName = activity.getPackageName() + ".flutter.image_provider";
  }

  public void chooseImageFromGallery(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      return;
    }

    boolean hasExternalStoragePermission =
        ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE)
            == PackageManager.PERMISSION_GRANTED;

    if (!hasExternalStoragePermission) {
      requestExternalStoragePermission();
      return;
    }

    launchPickImageFromGalleryIntent();
  }

  private void requestExternalStoragePermission() {
    ActivityCompat.requestPermissions(
        activity,
        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
        REQUEST_EXTERNAL_STORAGE_PERMISSION
    );
  }

  private void launchPickImageFromGalleryIntent() {
    Intent pickImageIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickImageIntent.setType("image/*");

    activity.startActivityForResult(pickImageIntent, REQUEST_CODE_CHOOSE_FROM_GALLERY);
  }

  public void takeImageWithCamera(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      return;
    }

    boolean hasCameraPermission =
        ActivityCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED;

    if (!hasCameraPermission) {
      requestCameraPermission();
      return;
    }

    launchTakeImageWithCameraIntent();
  }

  private void requestCameraPermission() {
    ActivityCompat.requestPermissions(
        activity,
        new String[] {Manifest.permission.CAMERA},
        REQUEST_CAMERA_PERMISSION
    );
  }

  private void launchTakeImageWithCameraIntent() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

    if (intent.resolveActivity(activity.getPackageManager()) != null) {
      File imageFile = createTemporaryWritableImageFile();
      pendingCameraImageUri = Uri.parse("file:" + imageFile.getAbsolutePath());

      Uri imageUri = FileProvider.getUriForFile(activity, providerName, imageFile);
      intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
      grantUriPermissions(intent, imageUri);

      activity.startActivityForResult(intent, REQUEST_CODE_TAKE_WITH_CAMERA);
    }
  }

  private File createTemporaryWritableImageFile() {
    String filename = UUID.randomUUID().toString();
    File image;

    try {
      image = File.createTempFile(filename, ".png", externalFilesDirectory);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }

    return image;
  }

  private void grantUriPermissions(Intent intent, Uri imageUri) {
    PackageManager packageManager = activity.getPackageManager();
    List<ResolveInfo> compatibleActivities =
        packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);

    for (ResolveInfo info : compatibleActivities) {
      activity.grantUriPermission(
          info.activityInfo.packageName,
          imageUri,
          Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION
      );
    }
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, String[] permissions, int[] grantResults) {
    boolean permissionGranted = grantResults.length > 0
        && grantResults[0] == PackageManager.PERMISSION_GRANTED;

    if (requestCode == REQUEST_EXTERNAL_STORAGE_PERMISSION) {
      if (permissionGranted) {
        launchPickImageFromGalleryIntent();
      } else {
        pendingResult.error(
            "no_permissions", "image_picker plugin requires storage permissions", null);
        clearMethodCallAndResult();
      }
      return true;
    } else if (requestCode == REQUEST_CAMERA_PERMISSION) {
      if (permissionGranted) {
        launchTakeImageWithCameraIntent();
      } else {
        pendingResult.error(
            "no_permissions", "image_picker plugin requires camera permissions", null);
        clearMethodCallAndResult();
      }
      return true;
    }
    return false;
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_CODE_CHOOSE_FROM_GALLERY) {
      handleChoosePictureResult(resultCode, data);
      return true;
    } else if (requestCode == REQUEST_CODE_TAKE_WITH_CAMERA) {
      handleTakePictureResult(resultCode);
      return true;
    }

    return false;
  }

  private void handleChoosePictureResult(int resultCode, Intent data) {
    if (resultCode == Activity.RESULT_OK && data != null) {
      String path = FileUtils.getPathFromUri(activity, data.getData());
      handleResult(path);
      return;
    }

    clearMethodCallAndResult();
  }

  private void handleTakePictureResult(int resultCode) {
    if (resultCode == Activity.RESULT_OK) {
      MediaScannerConnection.scanFile(
          activity,
          new String[]{pendingCameraImageUri.getPath()},
          null,
          new MediaScannerConnection.OnScanCompletedListener() {
            @Override
            public void onScanCompleted(String path, Uri uri) {
              handleResult(path);
            }
          });
      return;
    }

    clearMethodCallAndResult();
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

  private boolean setPendingMethodCallAndResult(MethodCall methodCall, MethodChannel.Result result) {
    if (pendingResult != null) {
      result.error("ALREADY_ACTIVE", "Image picker is already active", null);
      return false;
    }

    this.methodCall = methodCall;
    pendingResult = result;
    return true;
  }

  private void clearMethodCallAndResult() {
    methodCall = null;
    pendingResult = null;
  }
}
