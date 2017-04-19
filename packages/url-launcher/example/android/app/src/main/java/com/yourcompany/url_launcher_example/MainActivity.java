package com.yourcompany.url_launcher_example;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import com.yourcompany.url_launcher.UrlLauncherPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UrlLauncherPlugin.register(this);
    }
}
