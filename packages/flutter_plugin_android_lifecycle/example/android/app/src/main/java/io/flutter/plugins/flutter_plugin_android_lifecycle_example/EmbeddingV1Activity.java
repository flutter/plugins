package io.flutter.plugins.flutter_plugin_android_lifecycle_example;

import android.os.Bundle;
import dev.flutter.plugins.integration_test.integration_testPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.integration_testPlugin"));
    FlutterAndroidLifecyclePlugin.registerWith(
        registrarFor(
            "io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
  }
}
