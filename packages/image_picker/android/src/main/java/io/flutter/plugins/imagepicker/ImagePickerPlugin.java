// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Environment;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;

public class ImagePickerPlugin implements MethodChannel.MethodCallHandler {

  static final String METHOD_CALL_IMAGE = "pickImage";
  static final String METHOD_CALL_VIDEO = "pickVideo";
  private static final String METHOD_CALL_RETRIEVE = "retrieve";

  private static final String CHANNEL = "plugins.flutter.io/image_picker";

  private static final int SOURCE_CAMERA = 0;
  private static final int SOURCE_GALLERY = 1;

  private final PluginRegistry.Registrar registrar;
  private ImagePickerDelegate delegate;
  private Application.ActivityLifecycleCallbacks activityLifecycleCallbacks;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background flutter view tries to register the plugin, there will be no activity from the registrar,
      // we stop the registering process immediately because the ImagePicker requires an activity.
      return;
    }
    ImagePickerCache.setUpWithActivity(registrar.activity());

    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

    final File externalFilesDirectory =
        registrar.activity().getExternalFilesDir(Environment.DIRECTORY_PICTURES);
    final ExifDataCopier exifDataCopier = new ExifDataCopier();
    final ImageResizer imageResizer = new ImageResizer(externalFilesDirectory, exifDataCopier);
    final ImagePickerDelegate delegate =
        new ImagePickerDelegate(registrar.activity(), externalFilesDirectory, imageResizer);

    registrar.addActivityResultListener(delegate);
    registrar.addRequestPermissionsResultListener(delegate);
    final ImagePickerPlugin instance = new ImagePickerPlugin(registrar, delegate);
    channel.setMethodCallHandler(instance);
  }

  @VisibleForTesting
  ImagePickerPlugin(final PluginRegistry.Registrar registrar, final ImagePickerDelegate delegate) {
    this.registrar = registrar;
    this.delegate = delegate;
    this.activityLifecycleCallbacks =
        new Application.ActivityLifecycleCallbacks() {
          @Override
          public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

          @Override
          public void onActivityStarted(Activity activity) {}

          @Override
          public void onActivityResumed(Activity activity) {}

          @Override
          public void onActivityPaused(Activity activity) {}

          @Override
          public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
            if (activity == registrar.activity()) {
              delegate.saveStateBeforeResult();
            }
          }

          @Override
          public void onActivityDestroyed(Activity activity) {}

          @Override
          public void onActivityStopped(Activity activity) {}
        };

    if (this.registrar != null
        && this.registrar.activity() != null
        && this.registrar.activity().getApplication() != null) {
      this.registrar
          .activity()
          .getApplication()
          .registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (registrar.activity() == null) {
      result.error("no_activity", "image_picker plugin requires a foreground activity.", null);
      return;
    }
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
