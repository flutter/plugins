// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;
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

  private String getNetworkType(ConnectivityManager manager) {
    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Network network = manager.getActiveNetwork();
      NetworkCapabilities capabilities = manager.getNetworkCapabilities(network);
      if (capabilities == null) {
        return "none";
      }
      if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
          || capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
        return "wifi";
      }
      if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
        return "mobile";
      }
    }

    return getNetworkTypeLegacy(manager);
  }

  @SuppressWarnings("deprecation")
  private String getNetworkTypeLegacy(ConnectivityManager manager) {
    // handle type for Android versions less than Android 9
    NetworkInfo info = manager.getActiveNetworkInfo();
    if (info == null || !info.isConnected()) {
      return "none";
    }
    int type = info.getType();
    switch (type) {
      case ConnectivityManager.TYPE_ETHERNET:
      case ConnectivityManager.TYPE_WIFI:
      case ConnectivityManager.TYPE_WIMAX:
        return "wifi";
      case ConnectivityManager.TYPE_MOBILE:
      case ConnectivityManager.TYPE_MOBILE_DUN:
      case ConnectivityManager.TYPE_MOBILE_HIPRI:
        return "mobile";
      default:
        return "none";
    }
  }

  private static String getNetworkSubType(ConnectivityManager manager) {
    NetworkInfo info = manager.getActiveNetworkInfo();

    if (info == null || !info.isConnected()) return "none";

    /// Telephony Manager documentation  https://developer.android.com/reference/android/telephony/TelephonyManager
    /// Information about mobile broadband - https://en.wikipedia.org/wiki/Mobile_broadband#Generations
    switch (info.getSubtype()) {
      case TelephonyManager.NETWORK_TYPE_1xRTT: // ~ 50-100 kbps
      case TelephonyManager.NETWORK_TYPE_CDMA: // ~ 14-64 kbps
      case TelephonyManager.NETWORK_TYPE_EDGE: // ~ 50-100 kbps
      case TelephonyManager.NETWORK_TYPE_GPRS: // ~ 100 kbps
      case TelephonyManager.NETWORK_TYPE_IDEN: // API level 8  ~25 kbps
        return "2G";
      case TelephonyManager.NETWORK_TYPE_EVDO_0: // ~ 400-1000 kbps
      case TelephonyManager.NETWORK_TYPE_EVDO_A: // ~ 600-1400 kbps
      case TelephonyManager.NETWORK_TYPE_HSDPA: // ~ 2-14 Mbps
      case TelephonyManager.NETWORK_TYPE_HSPA: // ~ 700-1700 kbps
      case TelephonyManager.NETWORK_TYPE_HSUPA: // ~ 1-23 Mbps
      case TelephonyManager.NETWORK_TYPE_UMTS: // ~ 400-7000 kbps
      case TelephonyManager.NETWORK_TYPE_EHRPD: // API level 11  ~ 1-2 Mbps
      case TelephonyManager.NETWORK_TYPE_EVDO_B: // API level 9  ~ 5 Mbps
      case TelephonyManager.NETWORK_TYPE_HSPAP: // API level 13  ~ 10-20 Mbps
        return "3G";
      case TelephonyManager.NETWORK_TYPE_LTE: // API level 11 ~ 10+ Mbps
        return "4G";
      case TelephonyManager.NETWORK_TYPE_UNKNOWN:
        return "unknown"; // is connected but cannot tell the speed
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
      case "subtype":
        handleNetworkSubType(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleCheck(MethodCall call, final Result result) {
    result.success(checkNetworkType());
  }

  private void handleNetworkSubType(MethodCall call, final Result result) {
    result.success(getNetworkSubType(manager));
  }

  private String checkNetworkType() {
    return getNetworkType(manager) + "," + getNetworkSubType(manager);
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
        events.success(checkNetworkType());
      }
    };
  }
}
