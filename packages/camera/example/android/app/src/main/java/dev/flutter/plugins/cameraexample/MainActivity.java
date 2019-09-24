package dev.flutter.plugins.cameraexample;

import android.os.Bundle;

import dev.flutter.plugins.camera.CameraPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new CameraPlugin());
  }
}
