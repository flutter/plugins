package dev.flutter.plugins.urllauncherexample;

import dev.flutter.plugins.urllauncher.UrlLauncherPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new UrlLauncherPlugin());
  }
}
