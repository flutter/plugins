package io.flutter.plugins.androidalarmmanagerexample;

import android.annotation.SuppressLint;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.androidalarmmanager.AlarmService;
import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin;
import io.flutter.plugins.androidalarmmanager.FlutterAlarmManagerInitializer;

@SuppressWarnings("deprecation")
public class Application extends FlutterApplication
    implements io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback, FlutterAlarmManagerInitializer {
  @Override
  public void onCreate() {
    super.onCreate();

    AlarmService.setPluginRegistrant(this);
  }

  @Override
  @SuppressWarnings("deprecation")
  public void registerWith(io.flutter.plugin.common.PluginRegistry registry) {
    AndroidAlarmManagerPlugin.registerWith(
        registry.registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"));
  }

  @SuppressLint("LongLogTag")
  @Override
  public void configureAlarmManagerFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    // Initialize method channels, pigeons and etc here
    Log.i("FlutterAlarmManagerInitializer", "The engine initialized");
  }
}
