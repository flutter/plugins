// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.ScrollListenerFlutterApi;

/**
 * Flutter Api implementation for {@link ScrollListener}.
 *
 * <p>Passes arguments of callbacks methods from a {@link ScrollListener} to Dart.
 */
public class ScrollListenerFlutterApiImpl extends ScrollListenerFlutterApi {
  private final InstanceManager instanceManager;

  /**
   * Creates a Flutter api that sends messages to Dart.
   *
   * @param binaryMessenger handles sending messages to Dart
   * @param instanceManager maintains instances stored to communicate with Dart objects
   */
  public ScrollListenerFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /** Passes arguments from {@link ScrollListener#onScrollPosChange} to Dart. */
  public void onScrollPosChange(
      ScrollListener scrollChangeListener, long x, long y, Reply<Void> callback) {
    onScrollPosChange(getIdentifierForListener(scrollChangeListener), x, y, callback);
  }

  private long getIdentifierForListener(ScrollListener listener) {
    final Long identifier = instanceManager.getIdentifierForStrongReference(listener);
    if (identifier == null) {
      throw new IllegalStateException("Could not find identifier for OnScrollChangeListener.");
    }
    return identifier;
  }
}
