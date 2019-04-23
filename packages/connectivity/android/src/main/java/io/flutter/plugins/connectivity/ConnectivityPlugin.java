// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ConnectivityPlugin */
public class ConnectivityPlugin implements MethodCallHandler, StreamHandler {
  private final Registrar registrar;
  private final ConnectivityManager manager;
  private BroadcastReceiver receiver;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/connectivity");
    final EventChannel eventChannel =
        new EventChannel(registrar.messenger(), "plugins.flutter.io/connectivity_status");
    ConnectivityPlugin instance = new ConnectivityPlugin(registrar);
    channel.setMethodCallHandler(instance);
    eventChannel.setStreamHandler(instance);
  }

  private ConnectivityPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.manager =
        (ConnectivityManager)
            registrar
                .context()
                .getApplicationContext()
                .getSystemService(Context.CONNECTIVITY_SERVICE);
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    receiver = createReceiver(events);
    registrar
        .context()
        .registerReceiver(receiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
  }

  @Override
  public void onCancel(Object arguments) {
    registrar.context().unregisterReceiver(receiver);
    receiver = null;
  }

  private static String getNetworkType(int type) {
    switch (type) {
      case ConnectivityManager.TYPE_ETHERNET:
      case ConnectivityManager.TYPE_WIFI:
      case ConnectivityManager.TYPE_WIMAX:
        return "wifi";
      case ConnectivityManager.TYPE_MOBILE:
      case ConnectivityManager.TYPE_MOBILE_DUN:
        return "mobile";
      default:
        return "none";
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "check":
        handleCheck(call, result);
        break;
      case "wifiName":
        handleWifiName(call, result);
        break;
      case "wifiBSSID":
        handleBSSID(call, result);
        break;
      case "wifiIPAddress":
        handleWifiIPAddress(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleCheck(MethodCall call, final Result result) {
    NetworkInfo info = manager.getActiveNetworkInfo();
    if (info != null && info.isConnected()) {
      result.success(getNetworkType(info.getType()));
    } else {
      result.success("none");
    }
  }

  private WifiInfo getWifiInfo() {
    WifiManager wifiManager =
        (WifiManager)
            registrar.context().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    return wifiManager == null ? null : wifiManager.getConnectionInfo();
  }

  private void handleWifiName(MethodCall call, final Result result) {
    WifiInfo wifiInfo = getWifiInfo();
    String ssid = null;
    if (wifiInfo != null) ssid = wifiInfo.getSSID();
    if (ssid != null) ssid = ssid.replaceAll("\"", ""); // Android returns "SSID"
    result.success(ssid);
  }

  private void handleBSSID(MethodCall call, MethodChannel.Result result) {
    WifiInfo wifiInfo = getWifiInfo();
    String bssid = null;
    if (wifiInfo != null) bssid = wifiInfo.getBSSID();
    result.success(bssid);
  }

  private void handleWifiIPAddress(MethodCall call, final Result result) {
    WifiManager wifiManager =
        (WifiManager)
            registrar.context().getApplicationContext().getSystemService(Context.WIFI_SERVICE);

    WifiInfo wifiInfo = null;
    if (wifiManager != null) wifiInfo = wifiManager.getConnectionInfo();

    String ip = null;
    int i_ip = 0;
    if (wifiInfo != null) i_ip = wifiInfo.getIpAddress();

    if (i_ip != 0)
      ip =
          String.format(
              "%d.%d.%d.%d",
              (i_ip & 0xff), (i_ip >> 8 & 0xff), (i_ip >> 16 & 0xff), (i_ip >> 24 & 0xff));

    result.success(ip);
  }

  private BroadcastReceiver createReceiver(final EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        boolean isLost = intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false);
        if (isLost) {
          events.success("none");
          return;
        }

        int type = intent.getIntExtra(ConnectivityManager.EXTRA_NETWORK_TYPE, -1);
        events.success(getNetworkType(type));
      }
    };
  }
}
