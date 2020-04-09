// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import android.app.Activity;
import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** QuickActionsPlugin */
public class QuickActionsPlugin implements FlutterPlugin, ActivityAware {
  private static final String CHANNEL_ID = "plugins.flutter.io/quick_actions";

  private MethodChannel channel;
  private MethodCallHandlerImpl handler;

  /**
   * Plugin registration.
   *
   * <p>Must be called when the application is created.
   */
  public static void registerWith(Registrar registrar) {
    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    plugin.setupChannel(registrar.messenger(), registrar.context(), registrar.activity());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupChannel(binding.getBinaryMessenger(), binding.getApplicationContext(), null);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownChannel();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    handler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    handler.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  private void setupChannel(BinaryMessenger messenger, Context context, Activity activity) {
    channel = new MethodChannel(messenger, CHANNEL_ID);
    handler = new MethodCallHandlerImpl(context, activity);
    channel.setMethodCallHandler(handler);
  }

  private void teardownChannel() {
    channel.setMethodCallHandler(null);
    channel = null;
    handler = null;
  }
}
