
package io.flutter.plugins.pathproviderexample;

import android.os.Bundle;
import dev.flutter.plugins.integration_test.integration_testPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.pathprovider.PathProviderPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.integration_testPlugin"));
    PathProviderPlugin.registerWith(
        registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
  }
}
