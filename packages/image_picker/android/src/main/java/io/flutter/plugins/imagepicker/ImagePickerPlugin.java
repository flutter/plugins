// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.app.Activity;
import android.content.Intent;

import com.esafirm.imagepicker.features.ImagePicker;
import com.esafirm.imagepicker.features.camera.DefaultCameraModule;
import com.esafirm.imagepicker.features.camera.OnImageReadyListener;
import com.esafirm.imagepicker.model.Image;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class ImagePickerPlugin implements MethodCallHandler, ActivityResultListener {
  private static final String CHANNEL = "plugins.flutter.io/image_picker";

  public static final int REQUEST_CODE_PICK = 2342;
  public static final int REQUEST_CODE_CAMERA = 2343;

  private static final int SOURCE_ASK_USER = 0;
  private static final int SOURCE_CAMERA = 1;
  private static final int SOURCE_GALLERY = 2;

  private static final DefaultCameraModule cameraModule = new DefaultCameraModule();

  private final PluginRegistry.Registrar registrar;
  private final ImageResizer imageResizer;
  private final ExifDataCopier exifDataCopier;

  // Pending method call to obtain an image
  private Result pendingResult;
  private MethodCall methodCall;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    final ImagePickerPlugin instance = new ImagePickerPlugin(
            registrar,
            new ImageResizer(),
            new ExifDataCopier()
    );

    registrar.addActivityResultListener(instance);
    channel.setMethodCallHandler(instance);
  }

  private ImagePickerPlugin(
          PluginRegistry.Registrar registrar,
          ImageResizer imageResizer,
          ExifDataCopier exifDataCopier
  ) {
    this.registrar = registrar;
    this.imageResizer = imageResizer;
    this.exifDataCopier = exifDataCopier;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
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
        case SOURCE_ASK_USER:
          ImagePicker.create(activity).single().start(REQUEST_CODE_PICK);
          break;
        case SOURCE_GALLERY:
          ImagePicker.create(activity).single().showCamera(false).start(REQUEST_CODE_PICK);
          break;
        case SOURCE_CAMERA:
          activity.startActivityForResult(
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
        ArrayList<Image> images = (ArrayList<Image>) ImagePicker.getImages(data);
        handleResult(images.get(0));
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
                handleResult(images.get(0));
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

  private void handleResult(Image image) {
    if (pendingResult != null) {
      Double maxWidth = methodCall.argument("maxWidth");
      Double maxHeight = methodCall.argument("maxHeight");
      boolean shouldScale = maxWidth != null || maxHeight != null;

      if (!shouldScale) {
        pendingResult.success(image.getPath());
      } else {
        try {
          File scaledImage = imageResizer.resizedImage(image, maxWidth, maxHeight);
          exifDataCopier.copyExif(image.getPath(), scaledImage.getPath());
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
