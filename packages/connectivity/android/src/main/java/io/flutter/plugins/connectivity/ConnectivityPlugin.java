// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
<<<<<<< HEAD
import android.os.Build;
import android.telephony.TelephonyManager;
=======
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
>>>>>>> dce7169d302f1c5c1327692620458c9afd4b73d7
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ConnectivityPlugin */
public class ConnectivityPlugin implements FlutterPlugin {

  private MethodChannel methodChannel;
  private EventChannel eventChannel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {

    ConnectivityPlugin plugin = new ConnectivityPlugin();
    plugin.setupChannels(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupChannels(binding.getFlutterEngine().getDartExecutor(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownChannels();
  }

<<<<<<< HEAD
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

    if (info == null || !info.isConnected()) {
      return "none";
    }

    /// Telephony Manager documentation  https://developer.android.com/reference/android/telephony/TelephonyManager
    /// Information about mobile broadband - https://en.wikipedia.org/wiki/Mobile_broadband#Generations

    switch (info.getSubtype()) {
      case TelephonyManager.NETWORK_TYPE_1xRTT:
        {
          return "1xRTT"; // ~ 50-100 kbps
        }
      case TelephonyManager.NETWORK_TYPE_CDMA:
        {
          return "cdma"; // ~ 14-64 kbps
        }
      case TelephonyManager.NETWORK_TYPE_EDGE:
        {
          return "edge"; // ~ 50-100 kbps
        }
      case TelephonyManager.NETWORK_TYPE_EVDO_0:
        {
          return "evdo_0"; // ~ 400-1000 kbps
        }
      case TelephonyManager.NETWORK_TYPE_EVDO_A:
        {
          return "evdo_a"; // ~ 600-1400 kbps
        }
      case TelephonyManager.NETWORK_TYPE_GPRS:
        {
          return "gprs"; // ~ 100 kbps
        }
      case TelephonyManager.NETWORK_TYPE_HSDPA:
        {
          return "hsdpa"; // ~ 2-14 Mbps
        }
      case TelephonyManager.NETWORK_TYPE_HSPA:
        {
          return "hspa"; // ~ 700-1700 kbps
        }
      case TelephonyManager.NETWORK_TYPE_HSUPA:
        {
          return "hsupa"; // ~ 1-23 Mbps
        }
      case TelephonyManager.NETWORK_TYPE_UMTS:
        {
          return "umts"; // ~ 400-7000 kbps
        }
        /*
         * Above API level 7, make sure to set android:targetSdkVersion
         * to appropriate level to use these
         */
      case TelephonyManager.NETWORK_TYPE_EHRPD:
        { // API level 11
          return "ehrpd"; // ~ 1-2 Mbps
        }
      case TelephonyManager.NETWORK_TYPE_EVDO_B:
        { // API level 9
          return "evdo_b"; // ~ 5 Mbps
        }
      case TelephonyManager.NETWORK_TYPE_HSPAP:
        { // API level 13
          return "hspap"; // ~ 10-20 Mbps
        }
      case TelephonyManager.NETWORK_TYPE_IDEN:
        { // API level 8
          return "iden"; // ~25 kbps
        }
      case TelephonyManager.NETWORK_TYPE_LTE:
        { // API level 11
          return "lte"; // ~ 10+ Mbps
        }
        // Unknown
      case TelephonyManager.NETWORK_TYPE_UNKNOWN:
        {
          return "unknown"; // is connected but cannot tell the speed
        }
      default:
        {
          return "none";
        }
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
=======
  private void setupChannels(BinaryMessenger messenger, Context context) {
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/connectivity");
    eventChannel = new EventChannel(messenger, "plugins.flutter.io/connectivity_status");
    ConnectivityManager connectivityManager =
        (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
    WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
>>>>>>> dce7169d302f1c5c1327692620458c9afd4b73d7

    Connectivity connectivity = new Connectivity(connectivityManager, wifiManager);

    ConnectivityMethodChannelHandler methodChannelHandler =
        new ConnectivityMethodChannelHandler(connectivity);
    ConnectivityBroadcastReceiver receiver =
        new ConnectivityBroadcastReceiver(context, connectivity);

    methodChannel.setMethodCallHandler(methodChannelHandler);
    eventChannel.setStreamHandler(receiver);
  }

  private void teardownChannels() {
    methodChannel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
    methodChannel = null;
    eventChannel = null;
  }
}
