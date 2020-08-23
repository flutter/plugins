package io.flutter.plugins.googlemapsexample;

import android.os.Bundle;
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.googlemaps.GoogleMapsPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GoogleMapsPlugin.registerWith(registrarFor("io.flutter.plugins.googlemaps.GoogleMapsPlugin"));
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
  }
}
