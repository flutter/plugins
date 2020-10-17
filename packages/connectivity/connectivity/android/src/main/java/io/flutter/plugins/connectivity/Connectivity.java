// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;

import androidx.core.content.ContextCompat;

import io.flutter.Log;

/** Reports connectivity related information such as connectivity type and wifi information. */
class Connectivity {
  private ConnectivityManager connectivityManager;
  private WifiManager wifiManager;
  private Context context;
  private static final String TAG = "Connectivity";

  Connectivity(ConnectivityManager connectivityManager, WifiManager wifiManager, Context context) {
    this.connectivityManager = connectivityManager;
    this.wifiManager = wifiManager;
    this.context = context;
  }

  String getNetworkType() {
    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Network network = connectivityManager.getActiveNetwork();
      NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
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

    return getNetworkTypeLegacy();
  }

  String getWifiName() {
    if (!checkRequirement()) {
      return null;
    }
    WifiInfo wifiInfo = getWifiInfo();
    String ssid = null;
    if (wifiInfo != null) ssid = wifiInfo.getSSID();
    if (ssid != null) ssid = ssid.replaceAll("\"", ""); // Android returns "SSID"
    return ssid;
  }

  String getWifiBSSID() {
    if (!checkRequirement()) {
      return null;
    }
    WifiInfo wifiInfo = getWifiInfo();
    String bssid = null;
    if (wifiInfo != null) {
      bssid = wifiInfo.getBSSID();
    }
    return bssid;
  }

  String getWifiIPAddress() {
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

    return ip;
  }

  private WifiInfo getWifiInfo() {
    return wifiManager == null ? null : wifiManager.getConnectionInfo();
  }

  @SuppressWarnings("deprecation")
  private String getNetworkTypeLegacy() {
    // handle type for Android versions less than Android 9
    android.net.NetworkInfo info = connectivityManager.getActiveNetworkInfo();
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

  public ConnectivityManager getConnectivityManager() {
    return connectivityManager;
  }

  private Boolean checkRequirement() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return true;

    LocationManager locationManager =
            (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

    boolean gpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
    boolean permissionsGranted =
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) ==
                    PackageManager.PERMISSION_GRANTED;

    if (!permissionsGranted || !gpsEnabled) {
      Log.w(
              TAG,
              "Attempted to get Wi-Fi data that requires additional permission(s).\n"
                      + "For more information about Wi-Fi Restrictions in Android 8.0 and above, please consult the following link:\n"
                      + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
    }
    return permissionsGranted && gpsEnabled;
  }
}
