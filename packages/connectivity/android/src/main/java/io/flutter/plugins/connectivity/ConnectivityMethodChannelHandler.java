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
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ConnectivityMethodChannelHandler
    implements MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

  private final Context context;
  private ConnectivityManager manager;
  private BroadcastReceiver receiver;

  public ConnectivityMethodChannelHandler(Context context) {
    assert (context != null);
    this.context = context;
    this.manager =
        (ConnectivityManager)
            context.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    context.registerReceiver(receiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
  }

  @Override
  public void onCancel(Object arguments) {
    context.unregisterReceiver(receiver);
    receiver = null;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
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

  private BroadcastReceiver createReceiver(final EventChannel.EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        events.success(checkNetworkType());
      }
    };
  }

  private String checkNetworkType() {
    return getNetworkType(manager);
  }

  private void handleCheck(MethodCall call, final MethodChannel.Result result) {
    result.success(checkNetworkType());
  }

  private WifiInfo getWifiInfo() {
    WifiManager wifiManager =
        (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    return wifiManager == null ? null : wifiManager.getConnectionInfo();
  }

  private void handleWifiName(MethodCall call, final MethodChannel.Result result) {
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

  private void handleWifiIPAddress(MethodCall call, final MethodChannel.Result result) {
    WifiManager wifiManager =
        (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);

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
}
