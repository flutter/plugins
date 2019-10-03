package dev.flutter.plugins.androidintentexample;

import dev.flutter.plugins.androidintent.AndroidIntentPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new AndroidIntentPlugin());
  }
}
