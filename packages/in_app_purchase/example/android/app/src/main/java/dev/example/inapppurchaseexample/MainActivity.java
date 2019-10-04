package dev.example.inapppurchaseexample;

import dev.flutter.plugins.inapppurchase.InAppPurchasePlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new InAppPurchasePlugin());
  }
}
