package io.flutter.plugins.webviewflutterexample;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

// Extends FlutterActivity to make the FlutterEngine accessible for testing.
public class WebViewTestActivity extends FlutterActivity {
  public FlutterEngine engine;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    engine = flutterEngine;
  }
}
