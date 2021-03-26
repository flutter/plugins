package io.flutter.plugins.android_platform_images_example;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.android_platform_images.AndroidPlatformImagesPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        AndroidPlatformImagesPlugin.resourceMap.put("launch_icon", R.mipmap.ic_launcher);
        AndroidPlatformImagesPlugin.resourceMap.put("max_1_alias", R.drawable.max_1);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
    }
}
