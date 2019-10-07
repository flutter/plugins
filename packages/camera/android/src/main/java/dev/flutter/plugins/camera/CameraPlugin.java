// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.app.Activity;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import dev.flutter.plugins.camera.CameraPermissions.PermissionsRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

/**
 * Plugin implementation that uses the {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public final class CameraPlugin implements FlutterPlugin, ActivityAware {

  private static final String TAG = "CameraPlugin";
  private @Nullable FlutterPluginBinding flutterPluginBinding;
  private @Nullable MethodCallHandlerImpl methodCallHandler;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code dev.flutter.plugins.camera.MainActivity} for an example.
   */
  public CameraPlugin() {}

  /**
   * Registers a plugin implementation that uses the stable {@code io.flutter.plugin.common}
   * package.
   *
   * <p>Calling this automatically initializes the plugin. However plugins initialized this way
   * won't react to changes in activity or context, unlike {@link CameraPlugin}.
   */
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    CameraPlugin plugin = new CameraPlugin();
    plugin.startListening(
        registrar.activity(),
        registrar.messenger(),
        registrar::addRequestPermissionsResultListener,
        registrar.view());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    this.flutterPluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    this.flutterPluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    startListening(
        binding.getActivity(),
        flutterPluginBinding.getFlutterEngine().getDartExecutor(),
        binding::addRequestPermissionsResultListener,
        flutterPluginBinding.getFlutterEngine().getRenderer());
  }

  @Override
  public void onDetachedFromActivity() {
    if (methodCallHandler == null) {
      Log.wtf(TAG, "Detached before initialzed.");
      return;
    }

    methodCallHandler.stopListening();
    methodCallHandler = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  void startListening(
      Activity activity,
      BinaryMessenger messenger,
      PermissionsRegistry permissionsRegistry,
      TextureRegistry textureRegistry) {
    methodCallHandler =
        new MethodCallHandlerImpl(
            activity, messenger, new CameraPermissions(), permissionsRegistry, textureRegistry);
  }
}
