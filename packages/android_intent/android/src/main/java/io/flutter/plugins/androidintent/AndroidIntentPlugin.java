// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidintent;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public final class AndroidIntentPlugin implements FlutterPlugin, ActivityAware {
  private final IntentSender sender;
  private final MethodCallHandlerImpl impl;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code io.flutter.plugins.androidintentexample.MainActivity} for an example.
   */
  public AndroidIntentPlugin() {
    sender = new IntentSender(/*activity=*/ null, /*applicationContext=*/ null);
    impl = new MethodCallHandlerImpl(sender);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    sender.setApplicationContext(binding.getApplicationContext());
    sender.setActivity(null);
    impl.startListening(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    sender.setApplicationContext(null);
    sender.setActivity(null);
    impl.stopListening();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    sender.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    sender.setActivity(null);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }
}
