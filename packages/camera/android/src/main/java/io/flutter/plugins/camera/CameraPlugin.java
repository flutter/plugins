// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class CameraPlugin {

  public static void registerWith(Registrar registrar) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    CameraChannelHandler channelHandler = new CameraChannelHandler(
        registrar.activity(),
        registrar.view(),
        registrar.messenger(),
        new EventChannel(registrar.messenger(), "plugins.flutter.io/camera/imageStream"),
        new OldEmbeddingPermissions(registrar)
    );

    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/camera");

    channel.setMethodCallHandler(channelHandler);
  }

  private static class OldEmbeddingPermissions implements CameraPermissions.Permissions {
    private Registrar registrar;

    private OldEmbeddingPermissions(@NonNull Registrar registrar) {
      this.registrar = registrar;
    }

    @Override
    public Registrar addRequestPermissionsResultListener(PluginRegistry.RequestPermissionsResultListener listener) {
      return registrar.addRequestPermissionsResultListener(listener);
    }
  }
}
