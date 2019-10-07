package dev.flutter.plugins.sharedpreferencesexample;

import dev.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new SharedPreferencesPlugin());
  }
}
