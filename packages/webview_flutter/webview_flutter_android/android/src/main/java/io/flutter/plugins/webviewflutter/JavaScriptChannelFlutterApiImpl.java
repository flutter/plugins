// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.JavaScriptChannelFlutterApi;

/**
 * Flutter Api implementation for {@link JavaScriptChannel}.
 *
 * <p>Passes arguments of callbacks methods from a {@link JavaScriptChannel} to Dart.
 */
public class JavaScriptChannelFlutterApiImpl extends JavaScriptChannelFlutterApi {
  private final InstanceManager instanceManager;

  /**
   * Creates a Flutter api that sends messages to Dart.
   *
   * @param binaryMessenger Handles sending messages to Dart.
   * @param instanceManager Maintains instances stored to communicate with Dart objects.
   */
  public JavaScriptChannelFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /** Passes arguments from {@link JavaScriptChannel#postMessage} to Dart. */
  public void postMessage(
      JavaScriptChannel javaScriptChannel, String messageArg, Reply<Void> callback) {
    super.postMessage(instanceManager.getInstanceId(javaScriptChannel), messageArg, callback);
  }

  /**
   * Communicates to Dart that the reference to a {@link JavaScriptChannel} was removed.
   *
   * @param javaScriptChannel The instance whose reference will be removed.
   * @param callback Reply callback with return value from Dart.
   */
  public void dispose(JavaScriptChannel javaScriptChannel, Reply<Void> callback) {
    final Long instanceId = instanceManager.removeInstance(javaScriptChannel);
    if (instanceId != null) {
      dispose(instanceId, callback);
    } else {
      callback.reply(null);
    }
  }
}
