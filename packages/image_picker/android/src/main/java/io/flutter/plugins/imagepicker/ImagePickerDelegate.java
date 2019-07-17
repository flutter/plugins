// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static io.flutter.plugins.imagepicker.ImagePickerCache.*;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.provider.MediaStore;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.core.app.ActivityCompat;
import androidx.core.content.FileProvider;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.imagepicker.support.FileUtils;
import io.flutter.plugins.imagepicker.support.ImagePickerUtils;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
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
public class ImagePickerDelegate implements PickerDelegate {
  @VisibleForTesting static final int REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY = 2342;
  @VisibleForTesting static final int REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA = 2343;
  @VisibleForTesting static final int REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION = 2344;
  @VisibleForTesting static final int REQUEST_CAMERA_IMAGE_PERMISSION = 2345;
  @VisibleForTesting static final int REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY = 2352;
  @VisibleForTesting static final int REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA = 2353;
  @VisibleForTesting static final int REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION = 2354;
  @VisibleForTesting static final int REQUEST_CAMERA_VIDEO_PERMISSION = 2355;

  @VisibleForTesting final String fileProviderName;

  private final Activity activity;
  private final File externalFilesDirectory;
  private final ImageProcessor imageProcessor;
  private final ImagePickerCache cache;
  private final PermissionManager permissionManager;
  private final IntentResolver intentResolver;
  private final FileUriResolver fileUriResolver;
  private final FileUtils fileUtils;

  private Result pendingResult;

  ImagePickerDelegate(
      final Activity activity,
      File externalFilesDirectory,
      ImageProcessor imageProcessor,
      ImagePickerCache cache) {
    this(
        activity,
        externalFilesDirectory,
        imageProcessor,
        cache,
        null,
        new PermissionManager() {
          @Override
          public boolean isPermissionGranted(@NonNull String permissionName) {
            return ActivityCompat.checkSelfPermission(activity, permissionName)
                == PackageManager.PERMISSION_GRANTED;
          }

          @Override
          public void askForPermission(@NonNull String permissionName, int requestCode) {
            ActivityCompat.requestPermissions(activity, new String[] {permissionName}, requestCode);
          }

          @Override
          public boolean needRequestCameraPermission() {
            return ImagePickerUtils.needRequestCameraPermission(activity);
          }
        },
        new IntentResolver() {
          @Override
          public boolean resolveActivity(@NonNull Intent intent) {
            return intent.resolveActivity(activity.getPackageManager()) != null;
          }
        },
        new FileUriResolver() {
          @Override
          public Uri resolveFileProviderUriForFile(
              @NonNull String fileProviderName, @NonNull File file) {
            return FileProvider.getUriForFile(activity, fileProviderName, file);
          }

          @Override
          public void getFullImagePath(
              @Nullable final Uri imageUri, @NonNull final OnPathReadyListener listener) {
            MediaScannerConnection.scanFile(
                activity,
                new String[] {(imageUri != null) ? imageUri.getPath() : ""},
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
      ImageProcessor imageProcessor,
      ImagePickerCache cache,
      Result result,
      PermissionManager permissionManager,
      IntentResolver intentResolver,
      FileUriResolver fileUriResolver,
      FileUtils fileUtils) {
    this.activity = activity;
    this.externalFilesDirectory = externalFilesDirectory;
    this.imageProcessor = imageProcessor;
    this.fileProviderName = activity.getPackageName() + ".flutter.image_provider";
    this.cache = cache;
    this.pendingResult = result;
    this.permissionManager = permissionManager;
    this.intentResolver = intentResolver;
    this.fileUriResolver = fileUriResolver;
    this.fileUtils = fileUtils;
  }

  void retrieveLostImage(Result result) {
    Map<String, Object> resultMap = cache.getCacheMap();
    if (resultMap.isEmpty()) {
      result.success(null);
    } else {
      result.success(resultMap);
    }
    cache.clear();
  }

  @Override
  public void chooseVideoFromGallery(@NonNull MethodCall methodCall, @NonNull Result result) {
    if (!initRequest(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }

    final String permission = Manifest.permission.READ_EXTERNAL_STORAGE;
    if (!permissionManager.isPermissionGranted(permission)) {
      permissionManager.askForPermission(permission, REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION);
      return;
    }

    launchPickVideoFromGalleryIntent();
  }

  private void launchPickVideoFromGalleryIntent() {
    Intent pickVideoIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickVideoIntent.setType("video/*");

    activity.startActivityForResult(pickVideoIntent, REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY);
  }

  @Override
  public void takeVideoWithCamera(@NonNull MethodCall methodCall, @NonNull Result result) {
    if (!initRequest(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }
    final String permission = Manifest.permission.CAMERA;
    if (needRequestCameraPermission() && !permissionManager.isPermissionGranted(permission)) {
      permissionManager.askForPermission(permission, REQUEST_CAMERA_VIDEO_PERMISSION);
      return;
    }

    launchTakeVideoWithCameraIntent();
  }

  private void launchTakeVideoWithCameraIntent() {
    Intent intent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
    boolean canTakePhotos = intentResolver.resolveActivity(intent);

    if (!canTakePhotos) {
      finishWithError("no_available_camera", "No cameras available for taking pictures.");
      return;
    }

    File videoFile = createTemporaryWritableVideoFile();
    cache.savePendingCameraMediaUriPath(Uri.parse("file:" + videoFile.getAbsolutePath()));

    Uri videoUri = fileUriResolver.resolveFileProviderUriForFile(fileProviderName, videoFile);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, videoUri);
    grantUriPermissions(intent, videoUri);

    activity.startActivityForResult(intent, REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA);
  }

  @Override
  public void chooseImageFromGallery(@NonNull MethodCall methodCall, @NonNull Result result) {
    if (!initRequest(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }

    final String permission = Manifest.permission.READ_EXTERNAL_STORAGE;
    if (!permissionManager.isPermissionGranted(permission)) {
      permissionManager.askForPermission(permission, REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION);
      return;
    }

    launchPickImageFromGalleryIntent();
  }

  private void launchPickImageFromGalleryIntent() {
    Intent pickImageIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickImageIntent.setType("image/*");

    activity.startActivityForResult(pickImageIntent, REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY);
  }

  @Override
  public void takeImageWithCamera(@NonNull MethodCall methodCall, @NonNull Result result) {
    if (!initRequest(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }

    final String permission = Manifest.permission.CAMERA;
    if (needRequestCameraPermission() && !permissionManager.isPermissionGranted(permission)) {
      permissionManager.askForPermission(permission, REQUEST_CAMERA_IMAGE_PERMISSION);
      return;
    }

    launchTakeImageWithCameraIntent();
  }

  private boolean needRequestCameraPermission() {
    if (permissionManager == null) {
      return false;
    }
    return permissionManager.needRequestCameraPermission();
  }

  private void launchTakeImageWithCameraIntent() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    boolean canTakePhotos = intentResolver.resolveActivity(intent);

    if (!canTakePhotos) {
      finishWithError("no_available_camera", "No cameras available for taking pictures.");
      return;
    }

    File imageFile = createTemporaryWritableImageFile();
    cache.savePendingCameraMediaUriPath(Uri.parse("file:" + imageFile.getAbsolutePath()));

    Uri imageUri = fileUriResolver.resolveFileProviderUriForFile(fileProviderName, imageFile);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
    grantUriPermissions(intent, imageUri);

    activity.startActivityForResult(intent, REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA);
  }

  private File createTemporaryWritableImageFile() {
    return createTemporaryWritableFile(".jpg");
  }

  private File createTemporaryWritableVideoFile() {
    return createTemporaryWritableFile(".mp4");
  }

  private File createTemporaryWritableFile(String suffix) {
    String filename = UUID.randomUUID().toString();
    File image;

    try {
      image = File.createTempFile(filename, suffix, externalFilesDirectory);
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

    switch (requestCode) {
      case REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION:
        if (permissionGranted) {
          launchPickImageFromGalleryIntent();
        }
        break;
      case REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION:
        if (permissionGranted) {
          launchPickVideoFromGalleryIntent();
        }
        break;
      case REQUEST_CAMERA_IMAGE_PERMISSION:
        if (permissionGranted) {
          launchTakeImageWithCameraIntent();
        }
        break;
      case REQUEST_CAMERA_VIDEO_PERMISSION:
        if (permissionGranted) {
          launchTakeVideoWithCameraIntent();
        }
        break;
      default:
        return false;
    }

    if (!permissionGranted) {
      switch (requestCode) {
        case REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION:
        case REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION:
          finishWithError("photo_access_denied", "The user did not allow photo access.");
          break;
        case REQUEST_CAMERA_IMAGE_PERMISSION:
        case REQUEST_CAMERA_VIDEO_PERMISSION:
          finishWithError("camera_access_denied", "The user did not allow camera access.");
          break;
      }
    }

    return true;
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    switch (requestCode) {
      case REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY:
        handleChooseImageResult(resultCode, data);
        break;
      case REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA:
        handleCaptureImageResult(resultCode);
        break;
      case REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY:
        handleChooseVideoResult(resultCode, data);
        break;
      case REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA:
        handleCaptureVideoResult(resultCode);
        break;
      default:
        return false;
    }

    return true;
  }

  private void handleChooseImageResult(int resultCode, Intent data) {
    if (resultCode == Activity.RESULT_OK && data != null) {
      String path = fileUtils.getPathFromUri(activity, data.getData());
      handleImageResult(path, false);
      return;
    }

    // User cancelled choosing a picture.
    finishWithSuccess(null);
  }

  private void handleChooseVideoResult(int resultCode, Intent data) {
    if (resultCode == Activity.RESULT_OK && data != null) {
      String path = fileUtils.getPathFromUri(activity, data.getData());
      handleVideoResult(path);
      return;
    }

    // User cancelled choosing a video.
    finishWithSuccess(null);
  }

  private void handleCaptureImageResult(int resultCode) {
    if (resultCode == Activity.RESULT_OK) {
      final Uri path = Uri.parse(cache.retrievePendingCameraMediaUriPath());

      fileUriResolver.getFullImagePath(
          path,
          new OnPathReadyListener() {
            @Override
            public void onPathReady(@NonNull String path) {
              handleImageResult(path, true);
            }
          });
      return;
    }

    // User cancelled taking a picture.
    finishWithSuccess(null);
  }

  private void handleCaptureVideoResult(int resultCode) {
    if (resultCode == Activity.RESULT_OK) {
      final Uri path = Uri.parse(cache.retrievePendingCameraMediaUriPath());
      fileUriResolver.getFullImagePath(
          path,
          new OnPathReadyListener() {
            @Override
            public void onPathReady(String path) {
              handleVideoResult(path);
            }
          });
      return;
    }

    // User cancelled taking a picture.
    finishWithSuccess(null);
  }

  private void handleImageResult(String path, boolean shouldDeleteOriginalIfScaled) {

    final Map<String, Double> dimens = cache.getMaxDimensions();
    final double maxWidth = dimens.get(MAP_KEY_MAX_WIDTH);
    final double maxHeight = dimens.get(MAP_KEY_MAX_HEIGHT);

    String finalImagePath = imageProcessor.processImage(path, maxWidth, maxHeight);

    finishWithSuccess(finalImagePath);

    //delete original file if scaled
    if (!finalImagePath.equals(path) && shouldDeleteOriginalIfScaled) {
      new File(path).delete();
    }
  }

  private void handleVideoResult(String path) {
    finishWithSuccess(path);
  }

  private boolean initRequest(@NonNull MethodCall methodCall, @NonNull Result result) {
    if (pendingResult != null) {
      return false;
    }
    // Clean up cache if a new image picker is launched.
    cache.clear();

    cache.saveTypeWithMethodCallName(methodCall.method);
    cache.saveDimensionWithMethodCall(methodCall);

    pendingResult = result;

    return true;
  }

  private void finishWithSuccess(String imagePath) {
    cache.saveResult(imagePath, null, null);
    if (pendingResult != null) {
      pendingResult.success(imagePath);
      pendingResult = null;
      cache.clear();
    }
  }

  private void finishWithAlreadyActiveError(Result result) {
    result.error("already_active", "Image picker is already active", null);
  }

  private void finishWithError(String errorCode, String errorMessage) {
    cache.saveResult(null, errorCode, errorMessage);
    if (pendingResult != null) {
      pendingResult.error(errorCode, errorMessage, null);
      pendingResult = null;
      cache.clear();
    }
  }
}
