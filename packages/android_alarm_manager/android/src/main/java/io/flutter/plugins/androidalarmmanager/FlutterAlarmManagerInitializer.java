package io.flutter.plugins.androidalarmmanager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;

public interface FlutterAlarmManagerInitializer {
    void configureAlarmManagerFlutterEngine(@NonNull FlutterEngine flutterEngine);
}
