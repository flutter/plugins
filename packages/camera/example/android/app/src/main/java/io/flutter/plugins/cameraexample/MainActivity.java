package io.flutter.plugins.cameraexample;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.camera.CameraPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new CameraPlugin());

    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    PathProviderPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    VideoPlayerPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
  }
}
