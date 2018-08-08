package com.flutter.example.locationbackgroundplugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

// TODO(bkonyi): add Android implementation.
// This would likely involve something along the lines of:
// - Create a LocationBackgroundPluginService which extends Service
// - Use requestLocationUpdates with minDistance parameter set to 500m to match
//   iOS behaviour. See https://developer.android.com/reference/android/location/LocationManager
// - Similar plugin structure to `android_alarm_manager` found here:
//   https://github.com/flutter/plugins/tree/master/packages/android_alarm_manager
public class LocationBackgroundPlugin implements MethodCallHandler {
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "location_background_plugin");
    channel.setMethodCallHandler(new LocationBackgroundPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    result.notImplemented();
  }
}
