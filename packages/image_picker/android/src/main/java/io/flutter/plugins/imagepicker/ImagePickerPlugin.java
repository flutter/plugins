// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.content.Context;
import android.os.Environment;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.imagepicker.support.MethodResultWrapper;
import java.io.File;

public class ImagePickerPlugin implements MethodChannel.MethodCallHandler {

  static final String METHOD_CALL_IMAGE = "pickImage";
  static final String METHOD_CALL_VIDEO = "pickVideo";
  private static final String METHOD_CALL_RETRIEVE = "retrieve";

  private static final String CHANNEL = "plugins.flutter.io/image_picker";

  private static final int SOURCE_CAMERA = 0;
  private static final int SOURCE_GALLERY = 1;

  private ImagePickerDelegate delegate;


  public static void registerWith(PluginRegistry.Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background flutter view tries to register the plugin, there will be no activity from the registrar,
      // we stop the registering process immediately because the ImagePicker requires an activity.
      return;
    }
    final Context context = registrar.context();

    ImagePickerCache cache = new ImagePickerCache(context);

    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

    final File externalFilesDirectory = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
    final ImageProcessor imageProcessor = new ImageProcessor(externalFilesDirectory);
    final ImagePickerDelegate delegate =
      new ImagePickerDelegate(registrar.activity(), externalFilesDirectory, imageProcessor, cache);

    registrar.addActivityResultListener(delegate);
    registrar.addRequestPermissionsResultListener(delegate);
    final ImagePickerPlugin instance = new ImagePickerPlugin(delegate);
    channel.setMethodCallHandler(instance);
  }

  @VisibleForTesting
  ImagePickerPlugin(final ImagePickerDelegate delegate) {
    this.delegate = delegate;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result rawResult) {
    MethodChannel.Result result = new MethodResultWrapper(rawResult);
    int imageSource;

    switch (call.method) {
      case METHOD_CALL_IMAGE:
        imageSource = call.argument("source");
        switch (imageSource) {
          case SOURCE_GALLERY:
            delegate.chooseImageFromGallery(call, result);
            break;
          case SOURCE_CAMERA:
            delegate.takeImageWithCamera(call, result);
            break;
          default:
            throw new IllegalArgumentException("Invalid image source: " + imageSource);
        }
        break;
      case METHOD_CALL_VIDEO:
        imageSource = call.argument("source");
        switch (imageSource) {
          case SOURCE_GALLERY:
            delegate.chooseVideoFromGallery(call, result);
            break;
          case SOURCE_CAMERA:
            delegate.takeVideoWithCamera(call, result);
            break;
          default:
            throw new IllegalArgumentException("Invalid video source: " + imageSource);
        }
        break;
      case METHOD_CALL_RETRIEVE:
        delegate.retrieveLostImage(result);
        break;
      default:
        throw new IllegalArgumentException("Unknown method " + call.method);
    }
  }
}
