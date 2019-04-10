package io.flutter.plugins.camera;

import android.app.Activity;
import android.os.Build;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

public class CameraPlugin {
  private CameraPlugin(Registrar registrar, FlutterView view, Activity activity) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      new CameraHandler(registrar, view, activity);
    }
  }

  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }
    new CameraPlugin(registrar, registrar.view(), registrar.activity());
  }
}
