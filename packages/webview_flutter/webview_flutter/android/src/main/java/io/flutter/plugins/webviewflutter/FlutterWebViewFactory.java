// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.content.Context;
import android.view.View;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;

public final class FlutterWebViewFactory extends PlatformViewFactory {
  private final BinaryMessenger messenger;
  private final View containerView;

  FlutterWebViewFactory(BinaryMessenger messenger, View containerView) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
    this.containerView = containerView;
  }

  @SuppressWarnings("unchecked")
  @Override
  public PlatformView create(Context context, int id, Object args) {
    Map<String, Object> params = (Map<String, Object>) args;
    MethodChannel methodChannel = new MethodChannel(messenger, "plugins.flutter.io/webview_" + id);
    return new FlutterWebView(context, methodChannel, params, containerView);
  }
}
