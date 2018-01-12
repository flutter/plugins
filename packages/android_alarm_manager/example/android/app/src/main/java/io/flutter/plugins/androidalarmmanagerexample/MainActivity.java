package io.flutter.plugins.androidalarmmanagerexample;

import android.os.Bundle;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.androidalarmmanager.AlarmService;
import io.flutter.view.FlutterNativeView;

public class MainActivity extends FlutterActivity {
  public static final String TAG = "AlarmExampleMainActivity";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  public FlutterNativeView createFlutterNativeView() {
    Log.i(TAG, "createFlutterNativeView");
    return AlarmService.getSharedFlutterView();
  }
}
