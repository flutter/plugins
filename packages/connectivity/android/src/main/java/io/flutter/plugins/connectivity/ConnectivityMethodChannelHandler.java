package io.flutter.plugins.connectivity;

import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Handles MethodChannel and EventChannel for the plugin.
 */
public class ConnectivityMethodChannelHandler
    implements MethodChannel.MethodCallHandler {

  private WifiManager wifiManager;
  private ConnectivityChecker checker;

  /**
   * Construct the ConnectivityMethodChannelHandler
   *
   * @param checker The ConnectivityChecker used to check connectivity information.
   * @param wifiManager The wifiManager used to access wifi information.
   */
  public ConnectivityMethodChannelHandler(@NonNull ConnectivityChecker checker, @Nullable WifiManager wifiManager) {
    assert (checker != null);
    this.wifiManager = wifiManager;
    this.checker = checker;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "check":
        handleCheck(result);
        break;
      case "wifiName":
        handleWifiName(result);
        break;
      case "wifiBSSID":
        handleBSSID(result);
        break;
      case "wifiIPAddress":
        handleWifiIPAddress(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleCheck(final MethodChannel.Result result) {
    result.success(checker.checkNetworkType());
  }

  private WifiInfo getWifiInfo() {
    return wifiManager == null ? null : wifiManager.getConnectionInfo();
  }

  private void handleWifiName(final MethodChannel.Result result) {
    WifiInfo wifiInfo = getWifiInfo();
    String ssid = null;
    if (wifiInfo != null) ssid = wifiInfo.getSSID();
    if (ssid != null) ssid = ssid.replaceAll("\"", ""); // Android returns "SSID"
    result.success(ssid);
  }

  private void handleBSSID( MethodChannel.Result result) {
    WifiInfo wifiInfo = getWifiInfo();
    String bssid = null;
    if (wifiInfo != null) bssid = wifiInfo.getBSSID();
    result.success(bssid);
  }

  private void handleWifiIPAddress(final MethodChannel.Result result) {
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
