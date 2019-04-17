// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.provider.MediaStore;
import androidx.annotation.VisibleForTesting;
import androidx.core.app.ActivityCompat;
import androidx.core.content.FileProvider;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
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
public class ImagePickerDelegate
    implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener {
  @VisibleForTesting static final int REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY = 2342;
  @VisibleForTesting static final int REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA = 2343;
  @VisibleForTesting static final int REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION = 2344;
  @VisibleForTesting static final int REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY = 2352;
  @VisibleForTesting static final int REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA = 2353;
  @VisibleForTesting static final int REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION = 2354;

  @VisibleForTesting final String fileProviderName;

  static final String FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY = "flutter_image_picker_image_path";
  static final String SHARED_PREFERENCE_ERROR_CODE_KEY = "flutter_image_picker_error_code";
  static final String SHARED_PREFERENCE_ERROR_MESSAGE_KEY = "flutter_image_picker_error_message";
  static final String SHARED_PREFERENCE_MAX_WIDTH_KEY = "flutter_image_picker_max_width";
  static final String SHARED_PREFERENCE_MAX_HEIGHT_KEY = "flutter_image_picker_max_height";
  static final String SHARED_PREFERENCE_TYPE_KEY = "flutter_image_picker_type";
  static final String SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY =
      "flutter_image_picker_pending_image_uri";

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

  private Uri pendingCameraMediaUri;
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

  void retrieveLostImage(MethodChannel.Result result) {
    Map resultMap = resultMapFromPendingResult();
    if (resultMap.isEmpty()) {
      result.success(null);
    } else {
      result.success(resultMap);
    }
    cleanPendingResultPref();
  }

  public void chooseVideoFromGallery(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }
    setType("video");

    if (!permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)) {
      permissionManager.askForPermission(
          Manifest.permission.READ_EXTERNAL_STORAGE, REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION);
      return;
    }

    launchPickVideoFromGalleryIntent();
  }

  private void launchPickVideoFromGalleryIntent() {
    Intent pickVideoIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickVideoIntent.setType("video/*");

    activity.startActivityForResult(pickVideoIntent, REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY);
  }

  public void takeVideoWithCamera(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }
    setType("video");

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
    pendingCameraMediaUri = Uri.parse("file:" + videoFile.getAbsolutePath());
    persistsPendingCameraMediaUriPath("file:" + videoFile.getAbsolutePath());

    Uri videoUri = fileUriResolver.resolveFileProviderUriForFile(fileProviderName, videoFile);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, videoUri);
    grantUriPermissions(intent, videoUri);

    activity.startActivityForResult(intent, REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA);
  }

  public void chooseImageFromGallery(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }
    preparePersistentDataBeforeImageIntent(methodCall);

    if (!permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)) {
      permissionManager.askForPermission(
          Manifest.permission.READ_EXTERNAL_STORAGE, REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION);
      return;
    }

    launchPickImageFromGalleryIntent();
  }

  private void launchPickImageFromGalleryIntent() {
    Intent pickImageIntent = new Intent(Intent.ACTION_GET_CONTENT);
    pickImageIntent.setType("image/*");

    activity.startActivityForResult(pickImageIntent, REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY);
  }

  public void takeImageWithCamera(MethodCall methodCall, MethodChannel.Result result) {
    if (!setPendingMethodCallAndResult(methodCall, result)) {
      finishWithAlreadyActiveError(result);
      return;
    }
    preparePersistentDataBeforeImageIntent(methodCall);

    launchTakeImageWithCameraIntent();
  }

  private void preparePersistentDataBeforeImageIntent(MethodCall methodCall) {
    setType("image");
    Double maxWidth = methodCall.argument("maxWidth");
    Double maxHeight = methodCall.argument("maxHeight");
    saveMaxDimension(maxWidth, maxHeight);
  }

  private void launchTakeImageWithCameraIntent() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    boolean canTakePhotos = intentResolver.resolveActivity(intent);

    if (!canTakePhotos) {
      finishWithError("no_available_camera", "No cameras available for taking pictures.");
      return;
    }

    File imageFile = createTemporaryWritableImageFile();
    pendingCameraMediaUri = Uri.parse("file:" + imageFile.getAbsolutePath());
    persistsPendingCameraMediaUriPath("file:" + imageFile.getAbsolutePath());

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
      default:
        return false;
    }

    if (!permissionGranted) {
      finishWithSuccess(null);
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

    // User cancelled choosing a picture.
    finishWithSuccess(null);
  }

  private void handleCaptureImageResult(int resultCode) {
    if (resultCode == Activity.RESULT_OK) {
      fileUriResolver.getFullImagePath(
          pendingCameraMediaUri != null
              ? pendingCameraMediaUri
              : Uri.parse(getPersistedPendingCameraMediaUriPath()),
          new OnPathReadyListener() {
            @Override
            public void onPathReady(String path) {
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
      fileUriResolver.getFullImagePath(
          pendingCameraMediaUri != null
              ? pendingCameraMediaUri
              : Uri.parse(getPersistedPendingCameraMediaUriPath()),
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
    if (methodCall != null) {
      Double maxWidth = methodCall.argument("maxWidth");
      Double maxHeight = methodCall.argument("maxHeight");
      String finalImagePath = imageResizer.resizeImageIfNeeded(path, maxWidth, maxHeight);

      finishWithSuccess(finalImagePath);

      //delete original file if scaled
      if (!finalImagePath.equals(path) && shouldDeleteOriginalIfScaled) {
        new File(path).delete();
      }
    } else {
      finishWithSuccess(path);
    }
  }

  private String getFinalImagePath(String originalPath) {
    Double maxWidth = getMaxWidth();
    Double maxHeight = getMaxHeight();
    return imageResizer.resizeImageIfNeeded(originalPath, maxWidth, maxHeight);
  }

  private void handleVideoResult(String path) {
    finishWithSuccess(path);
  }

  private boolean setPendingMethodCallAndResult(
      MethodCall methodCall, MethodChannel.Result result) {
    if (pendingResult != null) {
      return false;
    }

    this.methodCall = methodCall;
    pendingResult = result;

    // Clean up old pending result preference if there is a new pending result.
    cleanPendingResultPref();

    return true;
  }

  private void finishWithSuccess(String imagePath) {
    if (pendingResult == null) {
      saveResult(imagePath, null, null);
      return;
    }
    pendingResult.success(imagePath);
    clearMethodCallAndResult();
  }

  private void finishWithAlreadyActiveError(MethodChannel.Result result) {
    result.error("already_active", "Image picker is already active", null);
  }

  private void finishWithError(String errorCode, String errorMessage) {
    if (pendingResult == null) {
      saveResult(null, errorCode, errorMessage);
      return;
    }
    pendingResult.error(errorCode, errorMessage, null);
    clearMethodCallAndResult();
  }

  private void clearMethodCallAndResult() {
    methodCall = null;
    pendingResult = null;
  }

  private void saveResult(String path, String errorCode, String errorMessage) {
    if (ImagePickerPlugin.getFilePref == null) {
      return;
    }
    SharedPreferences.Editor editor = ImagePickerPlugin.getFilePref.edit();
    if (path != null) {
      editor.putString(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY, path);
    }
    if (errorCode != null) {
      editor.putString(SHARED_PREFERENCE_ERROR_CODE_KEY, errorCode);
    }
    if (errorMessage != null) {
      editor.putString(SHARED_PREFERENCE_ERROR_MESSAGE_KEY, errorMessage);
    }
    editor.apply();
  }

  private void cleanPendingResultPref() {
    if (ImagePickerPlugin.getFilePref == null) {
      return;
    }
    ImagePickerPlugin.getFilePref.edit().clear().apply();
  }

  private Map<String, String> resultMapFromPendingResult() {
    if (ImagePickerPlugin.getFilePref == null) {
      return new HashMap<>();
    }
    Map<String, String> resultMap = new HashMap<>();
    Boolean hasData = false;
    String filePath =
        ImagePickerPlugin.getFilePref.getString(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY, null);
    if (filePath != null) {
      String finalPath = getFinalImagePath(filePath);
      resultMap.put("path", finalPath);
      hasData = true;
    }
    String errorCode =
        ImagePickerPlugin.getFilePref.getString(SHARED_PREFERENCE_ERROR_CODE_KEY, null);
    if (errorCode != null) {
      resultMap.put("errorCode", errorCode);
      hasData = true;
      String errorMessage =
          ImagePickerPlugin.getFilePref.getString(SHARED_PREFERENCE_ERROR_MESSAGE_KEY, null);
      if (errorMessage != null) {
        resultMap.put("errorMessage", errorMessage);
      }
    }

    if (hasData) {
      String type = ImagePickerPlugin.getFilePref.getString(SHARED_PREFERENCE_TYPE_KEY, null);
      if (type != null) {
        resultMap.put("type", type);
      }
    }
    return resultMap;
  }

  private Double getMaxWidth() {
    if (ImagePickerPlugin.getFilePref == null
        || !ImagePickerPlugin.getFilePref.contains(SHARED_PREFERENCE_MAX_WIDTH_KEY)) {
      return null;
    }
    return Double.longBitsToDouble(
        ImagePickerPlugin.getFilePref.getLong(SHARED_PREFERENCE_MAX_WIDTH_KEY, 0));
  }

  private Double getMaxHeight() {
    if (ImagePickerPlugin.getFilePref == null
        || !ImagePickerPlugin.getFilePref.contains(SHARED_PREFERENCE_MAX_HEIGHT_KEY)) {
      return null;
    }
    return Double.longBitsToDouble(
        ImagePickerPlugin.getFilePref.getLong(SHARED_PREFERENCE_MAX_HEIGHT_KEY, 0));
  }

  private void saveMaxDimension(Double maxWidth, Double maxHeight) {
    if (ImagePickerPlugin.getFilePref != null) {
      SharedPreferences.Editor editor = ImagePickerPlugin.getFilePref.edit();
      if (maxWidth != null) {
        editor.putLong(SHARED_PREFERENCE_MAX_WIDTH_KEY, Double.doubleToRawLongBits(maxWidth));
      }
      if (maxHeight != null) {
        editor.putLong(SHARED_PREFERENCE_MAX_HEIGHT_KEY, Double.doubleToRawLongBits(maxHeight));
      }
      editor.apply();
    }
  }

  private void setType(String type) {
    if (ImagePickerPlugin.getFilePref == null) {
      return;
    }
    ImagePickerPlugin.getFilePref.edit().putString(SHARED_PREFERENCE_TYPE_KEY, type).apply();
  }

  private void persistsPendingCameraMediaUriPath(String path) {
    if (ImagePickerPlugin.getFilePref != null) {
      ImagePickerPlugin.getFilePref
          .edit()
          .putString(SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY, path)
          .apply();
    }
  }

  private String getPersistedPendingCameraMediaUriPath() {
    if (ImagePickerPlugin.getFilePref == null) {
      return null;
    }
    return ImagePickerPlugin.getFilePref.getString(
        SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY, "");
  }
}
