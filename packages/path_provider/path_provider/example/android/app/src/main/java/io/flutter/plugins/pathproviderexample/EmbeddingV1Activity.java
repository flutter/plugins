
package io.flutter.plugins.pathproviderexample;

import android.os.Bundle;
import dev.flutter.plugins.integrationTest.IntegrationTestPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.pathprovider.PathProviderPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(registrarFor("dev.flutter.plugins.integrationTest.IntegrationTestPlugin"));
    PathProviderPlugin.registerWith(
        registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
  }
}
