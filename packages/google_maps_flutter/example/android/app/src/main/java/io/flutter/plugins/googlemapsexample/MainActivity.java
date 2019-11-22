package io.flutter.plugins.googlemapsexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.googlemaps.GoogleMapsPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
//    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
//    GeneratedPluginRegistrant.registerWith(shimPluginRegistry);
    flutterEngine.getPlugins().add(new GoogleMapsPlugin());
  }
}
