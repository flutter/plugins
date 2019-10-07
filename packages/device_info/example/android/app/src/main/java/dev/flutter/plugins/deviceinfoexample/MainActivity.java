package dev.flutter.plugins.deviceinfoexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.deviceinfo.DeviceInfoPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new DeviceInfoPlugin());
  }
}
