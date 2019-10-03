package io.flutter.plugins.batteryexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.battery.BatteryPlugin;

public class EmbedderV2Activity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new BatteryPlugin());
  }
}
