// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.wifi_info_flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * The handler receives {@link MethodCall}s from the UIThread, gets the related information from
 * a @{@link WifiInfoFlutter}, and then send the result back to the UIThread through the {@link
 * MethodChannel.Result}.
 */
class WifiInfoFlutterMethodChannelHandler implements MethodChannel.MethodCallHandler {
  private WifiInfoFlutter wifiInfoFlutter;

  /**
   * Construct the WifiInfoFlutterMethodChannelHandler with a {@code wifiInfoFlutter}. The {@code
   * wifiInfoFlutter} must not be null.
   */
  WifiInfoFlutterMethodChannelHandler(WifiInfoFlutter wifiInfoFlutter) {
    assert (wifiInfoFlutter != null);
    this.wifiInfoFlutter = wifiInfoFlutter;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "wifiName":
        result.success(wifiInfoFlutter.getWifiName());
        break;
      case "wifiBSSID":
        result.success(wifiInfoFlutter.getWifiBSSID());
        break;
      case "wifiIPAddress":
        result.success(wifiInfoFlutter.getWifiIPAddress());
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
