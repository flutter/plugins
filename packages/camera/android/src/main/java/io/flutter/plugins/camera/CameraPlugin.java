// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.util.SparseArray;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.camera.common.NativeTexture;
import io.flutter.plugins.camera.support_camera.SupportAndroidCamera;
import io.flutter.view.TextureRegistry;

public class CameraPlugin implements MethodCallHandler {
  private static final String CHANNEL_NAME = "dev.plugins/super_camera";
  private static final SparseArray<MethodChannel.MethodCallHandler> handlers = new SparseArray<>();

  private static Registrar registrar;

  private static MethodChannel.MethodCallHandler getHandler(final MethodCall call) {
    final Integer handle = call.argument("handle");

    if (handle == null) return null;
    return handlers.get(handle);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    CameraPlugin.registrar = registrar;
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new CameraPlugin());
  }

  private static void addHandler(final int handle, final MethodChannel.MethodCallHandler handler) {
    if (handlers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    handlers.put(handle, handler);
  }

  public static void removeHandler(final int handle) {
    handlers.remove(handle);
  }

  public static MethodChannel.MethodCallHandler getHandler(final int handle) {
    return handlers.get(handle);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "NativeTexture#allocate":
        allocateTexture(call, result);
        break;
      case "SupportAndroidCamera#getNumberOfCameras":
        result.success(SupportAndroidCamera.getNumberOfCameras());
        break;
      case "SupportAndroidCamera#getCameraInfo":
        result.success(SupportAndroidCamera.getCameraInfo(call));
        break;
      case "SupportAndroidCamera#open":
        final Integer cameraHandle = call.argument("cameraHandle");
        addHandler(cameraHandle, SupportAndroidCamera.open(call));
        result.success(null);
        break;
      default:
        final MethodChannel.MethodCallHandler handler = getHandler(call);

        if (handler == null) {
          result.notImplemented();
          break;
        }

        handler.onMethodCall(call, result);
    }
  }

  private void allocateTexture(MethodCall call, Result result) {
    final TextureRegistry.SurfaceTextureEntry entry = registrar.textures().createSurfaceTexture();
    final Integer textureHandle = call.argument("textureHandle");
    addHandler(textureHandle, new NativeTexture(entry, textureHandle));

    result.success(entry.id());
  }
}
