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
import android.provider.MediaStore;
import android.support.annotation.VisibleForTesting;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.FileProvider;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * A delegate class doing the heavy lifting for the plugin.
 *
 * <p>When invoked, both the {@link #chooseImageFromGallery} and {@link #takeImageWithCamera}
 * methods go through the same steps:
 *
 * <p>1. Check for an existing {@link #pendingResult}. If a previous pendingResult exists, this
 * means that the chooseImageFromGallery() or takeImageWithCamera() method was called at least
 * twice. In this case, stop executing and finish with an error.
 *
 * <p>2. Check that a required runtime permission has been granted. The chooseImageFromGallery()
 * method checks if the {@link Manifest.permission#READ_EXTERNAL_STORAGE} permission has been
 * granted. Similarly, the takeImageWithCamera() method checks that {@link
 * Manifest.permission#CAMERA} has been granted.
 *
 * <p>The permission check can end up in two different outcomes:
 *
 * <p>A) If the permission has already been granted, continue with picking the image from gallery or
 * camera.
 *
 * <p>B) If the permission hasn't already been granted, ask for the permission from the user. If the
 * user grants the permission, proceed with step #3. If the user denies the permission, stop doing
 * anything else and finish with a null result.
 *
 * <p>3. Launch the gallery or camera for picking the image, depending on whether
 * chooseImageFromGallery() or takeImageWithCamera() was called.
 *
 * <p>This can end up in three different outcomes:
 *
 * <p>A) User picks an image. No maxWidth or maxHeight was specified when calling {@code
 * pickImage()} method in the Dart side of this plugin. Finish with full path for the picked image
 * as the result.
 *
 * <p>B) User picks an image. A maxWidth and/or maxHeight was provided when calling {@code
 * pickImage()} method in the Dart side of this plugin. A scaled copy of the image is created.
 * Finish with full path for the scaled image as the result.
 *
 * <p>C) User cancels picking an image. Finish with null result.
 */
public class ImagePickerDelegate
    implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener {
  @VisibleForTesting static final int REQUEST_CODE_CHOOSE_FROM_GALLERY = 2342;
  @VisibleForTesting static final int REQUEST_CODE_TAKE_WITH_CAMERA = 2343;
  @VisibleForTesting static final int REQUEST_EXTERNAL_STORAGE_PERMISSION = 2344;
  @VisibleForTesting static final int REQUEST_CAMERA_PERMISSION = 2345;

  @VisibleForTesting final String fileProviderName;

  private final Activity activity;
  private final File externalFilesDirectory;
  private final ImageResizer imageResizer;
  private final PermissionManager permissionManager;
  private final IntentResolver intentResolver;
  private final FileUriResolver fileUriResolver;
  private final FileUtils fileUtils;

  interface PermissionManager {
    boolean isPermissionGranted(String permissionName);

    void askForPermission(String permissionName, int requestCode);
  }

  interface IntentResolver {
    boolean resolveActivity(Intent intent);
  }

  interface FileUriResolver {
    Uri resolveFileProviderUriForFile(String fileProviderName, File imageFile);

    void getFullImagePath(Uri imageUri, OnPathReadyListener listener);
  }

  interface OnPathReadyListener {
    void onPathReady(String path);
  }

  private Uri pendingCameraImageUri;
  private MethodChannel.Result pendingResult;
  private MethodCall methodCall;

  public ImagePickerDelegate(
      final Activity activity, File externalFilesDirectory, ImageResizer imageResizer) {
    this(
        activity,
        externalFilesDirectory,
        imageResizer,
        null,
        null,
        new PermissionManager() {
          @Override
          public boolean isPermissionGranted(String permissionName) {
            return ActivityCompat.checkSelfPermission(activity, permissionName)
                == PackageManager.PERMISSION_GRANTED;
          }

          @Override
          public void askForPermission(String permissionName, int requestCode) {
            ActivityCompat.requestPermissions(activity, new String[] {permissionName}, requestCode);
          }
        },
        new IntentResolver() {
          @Override
          public boolean resolveActivity(Intent intent) {
            return intent.resolveActivity(activity.getPackageManager()) != null;
          }
        },
        new FileUriResolver() {
          @Override
          public Uri resolveFileProviderUriForFile(String fileProviderName, File file) {
            return FileProvider.getUriForFile(activity, fileProviderName, file);
          }

          @Override
          public void getFullImagePath(final Uri imageUri, final OnPathReadyListener listener) {
            MediaScannerConnection.scanFile(
                activity,
                new String[] {imageUri.getPath()},
                null,
                new MediaScannerConnection.OnScanCompletedListener() {
                  @Override
                  public void onScanCompleted(String path, Uri uri) {
                    listener.onPathReady(path);
                  }
                });
          }
        },
        new FileUtils());
  }

  /**
   * This constructor is used exclusively for testing; it can be used to provide mocks to final
   * fields of this class. Otherwise those fields would have to be mutable and visible.
   */
  @VisibleForTesting
  ImagePickerDelegate(
      Activity activity,
      File externalFilesDirectory,
      ImageResizer imageResizer,
      MethodChannel.Result result,
      MethodCall methodCall,
      PermissionManager permissionManager,
      IntentResolver intentResolver,
      FileUriResolver fileUriResolver,
      FileUtils fileUtils) {
    this.activity = activity;
    this.externalFilesDirectory = externalFilesDirectory;
    this.imageResizer = imageResizer;
    this.fileProviderName = activity.getPackageName() + ".flutter.image_provider";
    this.pendingResult = result;
    this.methodCall = methodCall;
    this.permissionManager = permissionManager;
    this.intentResolver = intentResolver;
    this.fileUriResolver = fileUriResolver;
    this.fileUtils = fileUtils;
  }

  public void chooseImageFromGallery(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      finishWithAlreadyActiveError();
      return;
    }

    if (!permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)) {
      permissionManager.askForPermission(
          Manifest.permission.READ_EXTERNAL_STORAGE, REQUEST_EXTERNAL_STORAGE_PERMISSION);
      return;
    }

    launchPickImageFromGalleryIntent();
  }

  private void launchPickImageFromGalleryIntent() {
    Intent pickImageIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickImageIntent.setType("image/*");

    activity.startActivityForResult(pickImageIntent, REQUEST_CODE_CHOOSE_FROM_GALLERY);
  }

  public void takeImageWithCamera(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      finishWithAlreadyActiveError();
      return;
    }

    if (!permissionManager.isPermissionGranted(Manifest.permission.CAMERA)) {
      permissionManager.askForPermission(Manifest.permission.CAMERA, REQUEST_CAMERA_PERMISSION);
      return;
    }

    launchTakeImageWithCameraIntent();
  }

  private void launchTakeImageWithCameraIntent() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    boolean canTakePhotos = intentResolver.resolveActivity(intent);

    if (!canTakePhotos) {
      finishWithError("no_available_camera", "No cameras available for taking pictures.");
      return;
    }

    File imageFile = createTemporaryWritableImageFile();
    pendingCameraImageUri = Uri.parse("file:" + imageFile.getAbsolutePath());

    Uri imageUri = fileUriResolver.resolveFileProviderUriForFile(fileProviderName, imageFile);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
    grantUriPermissions(intent, imageUri);

    activity.startActivityForResult(intent, REQUEST_CODE_TAKE_WITH_CAMERA);
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
          Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
    }
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, String[] permissions, int[] grantResults) {
    boolean permissionGranted =
        grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;

    if (requestCode == REQUEST_EXTERNAL_STORAGE_PERMISSION) {
      if (permissionGranted) {
        launchPickImageFromGalleryIntent();
      } else {
        finishWithSuccess(null);
      }
      return true;
    } else if (requestCode == REQUEST_CAMERA_PERMISSION) {
      if (permissionGranted) {
        launchTakeImageWithCameraIntent();
      } else {
        finishWithSuccess(null);
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
      String path = fileUtils.getPathFromUri(activity, data.getData());
      handleResult(path);
      return;
    }

    // User cancelled choosing a picture.
    finishWithSuccess(null);
  }

  private void handleTakePictureResult(int resultCode) {
    if (resultCode == Activity.RESULT_OK) {
      fileUriResolver.getFullImagePath(
          pendingCameraImageUri,
          new OnPathReadyListener() {
            @Override
            public void onPathReady(String path) {
              handleResult(path);
            }
          });
      return;
    }

    // User cancelled taking a picture.
    finishWithSuccess(null);
  }

  private void handleResult(String path) {
    if (pendingResult != null) {
      Double maxWidth = methodCall.argument("maxWidth");
      Double maxHeight = methodCall.argument("maxHeight");

      String finalImagePath = imageResizer.resizeImageIfNeeded(path, maxWidth, maxHeight);
      finishWithSuccess(finalImagePath);
    } else {
      throw new IllegalStateException("Received images from picker that were not requested");
    }
  }

  private boolean setPendingMethodCallAndResult(
      MethodCall methodCall, MethodChannel.Result result) {
    if (pendingResult != null) {
      return false;
    }

    this.methodCall = methodCall;
    pendingResult = result;
    return true;
  }

  private void finishWithSuccess(String imagePath) {
    pendingResult.success(imagePath);
    clearMethodCallAndResult();
  }

  private void finishWithAlreadyActiveError() {
    finishWithError("already_active", "Image picker is already active");
  }

  private void finishWithError(String errorCode, String errorMessage) {
    pendingResult.error(errorCode, errorMessage, null);
    clearMethodCallAndResult();
  }

  private void clearMethodCallAndResult() {
    methodCall = null;
    pendingResult = null;
  }
}
