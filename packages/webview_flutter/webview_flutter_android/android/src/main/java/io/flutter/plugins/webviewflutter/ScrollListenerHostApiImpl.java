// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;


import androidx.annotation.NonNull;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.ScrollListenerHostApi;

/**
 * Host api implementation for {@link ScrollListener}.
 *
 * <p>Handles creating {@link ScrollListener}s that intercommunicate with a paired Dart object.
 */
public class ScrollListenerHostApiImpl implements ScrollListenerHostApi {
  private final InstanceManager instanceManager;
  private final ScrollListenerCreator scrollListenerCreator;
  private final ScrollListenerFlutterApiImpl flutterApi;

  /**
   * Implementation of {@link ScrollListener} that passes arguments of callback methods to Dart.
   */
  public static class ScrollListenerImpl implements ScrollListener {
    private final ScrollListenerFlutterApiImpl flutterApi;

    /**
     * Creates a {@link ScrollListenerImpl} that passes arguments of callbacks methods to Dart.
     *
     * @param flutterApi handles sending messages to Dart
     */
    public ScrollListenerImpl(@NonNull ScrollListenerFlutterApiImpl flutterApi) {
      this.flutterApi = flutterApi;
    }
    
    @Override
    public void onScrollPosChange(int x, int y) {
      flutterApi.onScrollPosChange(this, x, y, reply -> {});
    }
  }

  /** Handles creating {@link ScrollListenerImpl}s for a {@link ScrollListenerHostApiImpl}. */
  public static class ScrollListenerCreator {
    /**
     * Creates a {@link ScrollListenerImpl}.
     *
     * @param flutterApi handles sending messages to Dart
     * @return the created {@link ScrollListenerImpl}
     */
    public ScrollListenerImpl createScrollListener(ScrollListenerFlutterApiImpl flutterApi) {
      return new ScrollListenerImpl(flutterApi);
    }
  }

  /**
   * Creates a host API that handles creating {@link ScrollListener}.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param scrollListenerCreator handles creating {@link ScrollListenerHostApiImpl.ScrollListenerImpl}
   * @param flutterApi handles sending messages to Dart
   */
  public ScrollListenerHostApiImpl(
      InstanceManager instanceManager,
      ScrollListenerCreator scrollListenerCreator,
      ScrollListenerFlutterApiImpl flutterApi) {
    this.instanceManager = instanceManager;
    this.scrollListenerCreator = scrollListenerCreator;
    this.flutterApi = flutterApi;
  }

  @Override
  public void create(Long instanceId) {
    final ScrollListener scrollListener =
        scrollListenerCreator.createScrollListener(flutterApi);
    instanceManager.addDartCreatedInstance(scrollListener, instanceId);
  }
}
