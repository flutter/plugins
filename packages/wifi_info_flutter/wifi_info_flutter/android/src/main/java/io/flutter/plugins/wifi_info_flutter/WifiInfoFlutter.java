// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.wifi_info_flutter;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import androidx.core.content.ContextCompat;
import io.flutter.Log;

/** Reports wifi information. */
class WifiInfoFlutter {
  private WifiManager wifiManager;
  private Context context;
  private static final String TAG = "WifiInfoFlutter";

  WifiInfoFlutter(WifiManager wifiManager, Context context) {
    this.wifiManager = wifiManager;
    this.context = context;
  }

  String getWifiName() {
    if (!checkPermissions()) {
      return null;
    }
    final WifiInfo wifiInfo = getWifiInfo();
    String ssid = null;
    if (wifiInfo != null) ssid = wifiInfo.getSSID();
    if (ssid != null) ssid = ssid.replaceAll("\"", ""); // Android returns "SSID"
    if (ssid != null && ssid.equals("<unknown ssid>")) ssid = null;
    return ssid;
  }

  String getWifiBSSID() {
    if (!checkPermissions()) {
      return null;
    }
    final WifiInfo wifiInfo = getWifiInfo();
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

  private Boolean checkPermissions() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      return true;
    }

    boolean grantedChangeWifiState =
        ContextCompat.checkSelfPermission(context, Manifest.permission.CHANGE_WIFI_STATE)
            == PackageManager.PERMISSION_GRANTED;

    boolean grantedAccessFine =
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED;

    boolean grantedAccessCoarse =
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
            == PackageManager.PERMISSION_GRANTED;

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P
        && !grantedChangeWifiState
        && !grantedAccessFine
        && !grantedAccessCoarse) {
      Log.w(
          TAG,
          "Attempted to get Wi-Fi data that requires additional permission(s).\n"
              + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android O, please ensure your app has one of the following permissions:\n"
              + "- CHANGE_WIFI_STATE\n"
              + "- ACCESS_FINE_LOCATION\n"
              + "- ACCESS_COARSE_LOCATION\n"
              + "For more information about Wi-Fi Restrictions in Android 8.0 and above, please consult the following link:\n"
              + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
    }

    if (Build.VERSION.SDK_INT == Build.VERSION_CODES.P && !grantedChangeWifiState) {
      Log.w(
          TAG,
          "Attempted to get Wi-Fi data that requires additional permission(s).\n"
              + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android P, please ensure your app has the CHANGE_WIFI_STATE permission.\n"
              + "For more information about Wi-Fi Restrictions in Android 9.0 and above, please consult the following link:\n"
              + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
    }

    if (Build.VERSION.SDK_INT == Build.VERSION_CODES.P
        && !grantedAccessFine
        && !grantedAccessCoarse) {
      Log.w(
          TAG,
          "Attempted to get Wi-Fi data that requires additional permission(s).\n"
              + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android P, additional to CHANGE_WIFI_STATE please ensure your app has one of the following permissions too:\n"
              + "- ACCESS_FINE_LOCATION\n"
              + "- ACCESS_COARSE_LOCATION\n"
              + "For more information about Wi-Fi Restrictions in Android 9.0 and above, please consult the following link:\n"
              + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        && (!grantedAccessFine || !grantedChangeWifiState)) {
      Log.w(
          TAG,
          "Attempted to get Wi-Fi data that requires additional permission(s).\n"
              + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android Q, please ensure your app has the CHANGE_WIFI_STATE and ACCESS_FINE_LOCATION permission.\n"
              + "For more information about Wi-Fi Restrictions in Android 10.0 and above, please consult the following link:\n"
              + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
    }

    LocationManager locationManager =
        (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

    boolean gpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && !gpsEnabled) {
      Log.w(
          TAG,
          "Attempted to get Wi-Fi data that requires additional permission(s).\n"
              + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android P, please ensure Location services are enabled on the device (under Settings > Location).\n"
              + "For more information about Wi-Fi Restrictions in Android 9.0 and above, please consult the following link:\n"
              + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
    }
    return true;
  }
}
