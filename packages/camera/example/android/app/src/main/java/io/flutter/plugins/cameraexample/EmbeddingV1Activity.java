package io.flutter.plugins.cameraexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.camera.CameraPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    CameraPlugin.registerWith(registrarFor("io.flutter.plugins.camera.CameraPlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
    PathProviderPlugin.registerWith(
        registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    VideoPlayerPlugin.registerWith(
        registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
  }
}
