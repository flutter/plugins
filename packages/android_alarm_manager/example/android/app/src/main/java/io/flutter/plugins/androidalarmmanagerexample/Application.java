package io.flutter.plugins.androidalarmmanagerexample;

import io.flutter.app.FlutterApplication;
import io.flutter.plugins.androidalarmmanager.AlarmService;
import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin;

@SuppressWarnings("deprecation")
public class Application extends FlutterApplication
    implements io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback {
  @Override
  public void onCreate() {
    super.onCreate();
    AlarmService.setPluginRegistrant(this);
  }

  @Override
  @SuppressWarnings("deprecation")
  public void registerWith(io.flutter.plugin.common.PluginRegistry registry) {
    AndroidAlarmManagerPlugin.registerWith(
        registry.registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"));
  }
}
