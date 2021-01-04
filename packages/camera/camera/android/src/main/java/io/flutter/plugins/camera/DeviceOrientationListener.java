package io.flutter.plugins.camera;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.view.Surface;
import android.view.WindowManager;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;

class DeviceOrientationListener {
  private static final IntentFilter orientationIntentFilter =
      new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final Context context;
  private BroadcastReceiver broadcastReceiver;
  private DartMessenger messenger;
  private PlatformChannel.DeviceOrientation lastOrientation;

  public DeviceOrientationListener(Context context, DartMessenger messenger) {
    this.context = context;
    this.messenger = messenger;
  }

  public void start() {
    if (broadcastReceiver != null) return;

    broadcastReceiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            PlatformChannel.DeviceOrientation orientation = getOrientation();
            if (orientation == null || lastOrientation == orientation) return;
            lastOrientation = orientation;
            messenger.sendDeviceOrientationChangeEvent(orientation);
          }
        };

    context.registerReceiver(broadcastReceiver, orientationIntentFilter);
    // Trigger initial value
    broadcastReceiver.onReceive(context, null);
  }

  public void stop() {
    if (broadcastReceiver == null) return;
    context.unregisterReceiver(broadcastReceiver);
    broadcastReceiver = null;
  }

  private PlatformChannel.DeviceOrientation getOrientation() {
    final int rotation =
        ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE))
            .getDefaultDisplay()
            .getRotation();
    final int orientation = context.getResources().getConfiguration().orientation;
    switch (orientation) {
      case Configuration.ORIENTATION_PORTRAIT:
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
          return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
        } else {
          return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
        }
      case Configuration.ORIENTATION_LANDSCAPE:
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
          return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
        } else {
          return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
        }
      default:
        return null;
    }
  }
}
