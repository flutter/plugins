package io.flutter.plugins.flutter_plugin_android_lifecycle_example;

import android.os.Bundle;
import dev.flutter.plugins.integrationTest.IntegrationTestPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(registrarFor("dev.flutter.plugins.integrationTest.IntegrationTestPlugin"));
    FlutterAndroidLifecyclePlugin.registerWith(
        registrarFor(
            "io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
  }
}
