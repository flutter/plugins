// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.content.Context;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import android.os.Build;
import android.webkit.WebSettings;
import android.webkit.WebView;

class FlutterWebViewFactory extends PlatformViewFactory {
  private final InstanceManager instanceManager;

  FlutterWebViewFactory(InstanceManager instanceManager) {
    super(StandardMessageCodec.INSTANCE);
    this.instanceManager = instanceManager;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
   final PlatformView view = (PlatformView) instanceManager.getInstance(
      (Integer) args
    );
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) { // 5.0 以上强制启用 https 和 http 混用模式
      if (view instanceof WebView) {
        ((WebView) view).getSettings()
          .setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
      }
    }
    if (view == null) {
      throw new IllegalStateException(
        "Unable to find WebView instance: " + args
      );
    }
    return view;
  }
}
