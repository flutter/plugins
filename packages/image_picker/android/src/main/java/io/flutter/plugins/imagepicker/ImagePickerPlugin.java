// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class ImagePickerPlugin implements MethodChannel.MethodCallHandler {
  private static final String CHANNEL = "plugins.flutter.io/image_picker";

  private static final int SOURCE_CAMERA = 0;
  private static final int SOURCE_GALLERY = 1;

  private final PluginRegistry.Registrar registrar;
  private final ImagePickerDelegate delegate;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

    final ExifDataCopier exifDataCopier = new ExifDataCopier();
    final ImageResizer imageResizer = new ImageResizer(exifDataCopier);

    final ImagePickerDelegate delegate =
        new ImagePickerDelegate(registrar.activity(), imageResizer);
    registrar.addActivityResultListener(delegate);
    registrar.addRequestPermissionsResultListener(delegate);

    final ImagePickerPlugin instance = new ImagePickerPlugin(registrar, delegate);
    channel.setMethodCallHandler(instance);
  }

  private ImagePickerPlugin(PluginRegistry.Registrar registrar, ImagePickerDelegate delegate) {
    this.registrar = registrar;
    this.delegate = delegate;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    ensureActivityIsInForeground(result);

    if (call.method.equals("pickImage")) {
      int imageSource = call.argument("source");

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
    } else {
      throw new IllegalArgumentException("Unknown method " + call.method);
    }
  }

  private void ensureActivityIsInForeground(MethodChannel.Result result) {
    if (registrar.activity() == null) {
      result.error("no_activity", "image_picker plugin requires a foreground activity.", null);
    }
  }
}
