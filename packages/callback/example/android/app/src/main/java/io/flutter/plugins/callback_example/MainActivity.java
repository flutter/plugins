package io.flutter.plugins.callback_example;

import android.os.Bundle;

import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.callback.CallbackPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    CallbackPlugin plugin = valuePublishedByPlugin("io.flutter.plugins.callback.CallbackPlugin");
    plugin.registerCallback("hello_world", new Runnable() {
      @Override
      public void run() {
        Log.w("CallbackSampleApp", "Hello World!");
      }
    });
  }
}
