package dev.flutter.plugins.pathproviderexample;

import dev.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new PathProviderPlugin());
  }
}
