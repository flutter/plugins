package io.flutter.plugins.connectivity;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * The handler receives method channel calls from the UIThread, gets the related information from
 * a @{@link Connectivity}, and then send the result back to the UIThread through the method
 * channel.
 */
public class ConnectivityMethodChannelHandler implements MethodChannel.MethodCallHandler {

  private Connectivity connectivity;

  /**
   * Construct the ConnectivityMethodChannelHandler with a {@code connectivity}. The {@code
   * connectivity} must not be null.
   */
  public ConnectivityMethodChannelHandler(@NonNull Connectivity connectivity) {
    assert (connectivity != null);
    this.connectivity = connectivity;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "check":
        result.success(connectivity.checkNetworkType());
        break;
      case "wifiName":
        result.success(connectivity.getWifiName());
        break;
      case "wifiBSSID":
        result.success(connectivity.getWifiBSSID());
        break;
      case "wifiIPAddress":
        result.success(connectivity.getWifiIPAddress());
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
