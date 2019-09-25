package dev.flutter.plugins.cameraexample;

import dev.flutter.plugins.camera.CameraPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    // TODO(mattcarroll): need to migrate path provider plugin to support picture and video recording
    flutterEngine.getPlugins().add(new CameraPlugin());
  }
}
