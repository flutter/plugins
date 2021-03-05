// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.hardware.SensorManager;
import android.provider.Settings;
import android.view.Display;
import android.view.OrientationEventListener;
import android.view.Surface;
import android.view.WindowManager;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;

class DeviceOrientationManager {

  private static final IntentFilter orientationIntentFilter =
      new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final Activity activity;
  private final DartMessenger messenger;
  private final boolean isFrontFacing;
  private final int sensorOrientation;
  private PlatformChannel.DeviceOrientation lastOrientation;
  private OrientationEventListener orientationEventListener;
  private BroadcastReceiver broadcastReceiver;

  /**
  * Factory method to create a device orientation manager.
  */
  public static DeviceOrientationManager create(
      Activity activity,
      DartMessenger messenger,
      boolean isFrontFacing,
      int sensorOrientation
  ) {
    return new DeviceOrientationManager(activity, messenger, isFrontFacing, sensorOrientation);
  }

  private DeviceOrientationManager(
      Activity activity, DartMessenger messenger, boolean isFrontFacing, int sensorOrientation) {
    this.activity = activity;
    this.messenger = messenger;
    this.isFrontFacing = isFrontFacing;
    this.sensorOrientation = sensorOrientation;
  }

  public void start() {
    startSensorListener();
    startUIListener();
  }

  public void stop() {
    stopSensorListener();
    stopUIListener();
  }

  public int getMediaOrientation() {
    return this.getMediaOrientation(this.lastOrientation);
  }

  public int getMediaOrientation(PlatformChannel.DeviceOrientation orientation) {
    int angle = 0;

    // Fallback to device orientation when the orientation value is null
    if (orientation == null) {
      orientation = getUIOrientation();
    }

    switch (orientation) {
      case PORTRAIT_UP:
        angle = 0;
        break;
      case PORTRAIT_DOWN:
        angle = 180;
        break;
      case LANDSCAPE_LEFT:
        angle = 90;
        break;
      case LANDSCAPE_RIGHT:
        angle = 270;
        break;
    }
    if (isFrontFacing) angle *= -1;
    return (angle + sensorOrientation + 360) % 360;
  }

  private void startSensorListener() {
    if (orientationEventListener != null) return;
    orientationEventListener =
        new OrientationEventListener(activity, SensorManager.SENSOR_DELAY_NORMAL) {
          @Override
          public void onOrientationChanged(int angle) {
            if (!isSystemAutoRotationLocked()) {
              PlatformChannel.DeviceOrientation newOrientation = calculateSensorOrientation(angle);
              if (!newOrientation.equals(lastOrientation)) {
                lastOrientation = newOrientation;
                messenger.sendDeviceOrientationChangeEvent(newOrientation);
              }
            }
          }
        };
    if (orientationEventListener.canDetectOrientation()) {
      orientationEventListener.enable();
    }
  }

  private void startUIListener() {
    if (broadcastReceiver != null) return;
    broadcastReceiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            if (isSystemAutoRotationLocked()) {
              PlatformChannel.DeviceOrientation orientation = getUIOrientation();
              if (!orientation.equals(lastOrientation)) {
                lastOrientation = orientation;
                messenger.sendDeviceOrientationChangeEvent(orientation);
              }
            }
          }
        };
    activity.registerReceiver(broadcastReceiver, orientationIntentFilter);
    broadcastReceiver.onReceive(activity, null);
  }

  private void stopSensorListener() {
    if (orientationEventListener == null) return;
    orientationEventListener.disable();
    orientationEventListener = null;
  }

  private void stopUIListener() {
    if (broadcastReceiver == null) return;
    activity.unregisterReceiver(broadcastReceiver);
    broadcastReceiver = null;
  }

  private boolean isSystemAutoRotationLocked() {
    return android.provider.Settings.System.getInt(
            activity.getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0)
        != 1;
  }

  private PlatformChannel.DeviceOrientation getUIOrientation() {
    final int rotation = getDisplay().getRotation();
    final int orientation = activity.getResources().getConfiguration().orientation;

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
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
    }
  }

  private PlatformChannel.DeviceOrientation calculateSensorOrientation(int angle) {
    final int tolerance = 45;
    angle += tolerance;

    // Orientation is 0 in the default orientation mode. This is portait-mode for phones
    // and landscape for tablets. We have to compensate for this by calculating the default
    // orientation, and apply an offset accordingly.
    int defaultDeviceOrientation = getDeviceDefaultOrientation();
    if (defaultDeviceOrientation == Configuration.ORIENTATION_LANDSCAPE) {
      angle += 90;
    }
    // Determine the orientation
    angle = angle % 360;
    return new PlatformChannel.DeviceOrientation[] {
          PlatformChannel.DeviceOrientation.PORTRAIT_UP,
          PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT,
          PlatformChannel.DeviceOrientation.PORTRAIT_DOWN,
          PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT,
        }
        [angle / 90];
  }

  private int getDeviceDefaultOrientation() {
    Configuration config = activity.getResources().getConfiguration();
    int rotation = getDisplay().getRotation();
    if (((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180)
            && config.orientation == Configuration.ORIENTATION_LANDSCAPE)
        || ((rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270)
            && config.orientation == Configuration.ORIENTATION_PORTRAIT)) {
      return Configuration.ORIENTATION_LANDSCAPE;
    } else {
      return Configuration.ORIENTATION_PORTRAIT;
    }
  }

  @SuppressWarnings("deprecation")
  private Display getDisplay() {
    return ((WindowManager) activity.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
  }
}
