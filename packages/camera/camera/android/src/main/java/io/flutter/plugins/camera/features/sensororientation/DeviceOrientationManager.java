// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.sensororientation;

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
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import io.flutter.plugins.camera.DartMessenger;

/**
 * Support class to help to determine the media orientation based on the orientation of the device.
 */
public class DeviceOrientationManager {

  private static final IntentFilter orientationIntentFilter =
      new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final Activity activity;
  private final DartMessenger messenger;
  private final boolean isFrontFacing;
  private final int sensorOrientation;
  private PlatformChannel.DeviceOrientation lastOrientation;
  private OrientationEventListener orientationEventListener;
  private BroadcastReceiver broadcastReceiver;

  /** Factory method to create a device orientation manager. */
  public static DeviceOrientationManager create(
      @NonNull Activity activity,
      @NonNull DartMessenger messenger,
      boolean isFrontFacing,
      int sensorOrientation) {
    return new DeviceOrientationManager(activity, messenger, isFrontFacing, sensorOrientation);
  }

  private DeviceOrientationManager(
      @NonNull Activity activity,
      @NonNull DartMessenger messenger,
      boolean isFrontFacing,
      int sensorOrientation) {
    this.activity = activity;
    this.messenger = messenger;
    this.isFrontFacing = isFrontFacing;
    this.sensorOrientation = sensorOrientation;
  }

  /**
   * Starts listening to the device's sensors or UI for orientation updates.
   *
   * <p>When orientation information is updated the new orientation is send to the client using the
   * {@link DartMessenger}. This latest value can also be retrieved through the {@link
   * #getMediaOrientation()} accessor.
   *
   * <p>If the device's ACCELEROMETER_ROTATION setting is enabled the {@link
   * DeviceOrientationManager} will report orientation updates based on the sensor information. If
   * the ACCELEROMETER_ROTATION is disabled the {@link DeviceOrientationManager} will fallback to
   * the deliver orientation updates based on the UI orientation.
   */
  public void start() {
    startSensorListener();
    startUIListener();
  }

  /** Stops listening for orientation updates. */
  public void stop() {
    stopSensorListener();
    stopUIListener();
  }

  /**
   * Returns the last captured orientation in degrees based on sensor or UI information.
   *
   * <p>The orientation is returned in degrees and could be one of the following values:
   *
   * <ul>
   *   <li>0: Indicates the device is currently in portrait.
   *   <li>90: Indicates the device is currently in landscape left.
   *   <li>180: Indicates the device is currently in portrait down.
   *   <li>270: Indicates the device is currently in landscape right.
   * </ul>
   *
   * @return The last captured orientation in degrees
   */
  public int getMediaOrientation() {
    return this.getMediaOrientation(this.lastOrientation);
  }

  /**
   * Returns the device's orientation in degrees based on the supplied {@link
   * PlatformChannel.DeviceOrientation} value.
   *
   * <p>
   *
   * <ul>
   *   <li>PORTRAIT_UP: converts to 0 degrees.
   *   <li>LANDSCAPE_LEFT: converts to 90 degrees.
   *   <li>PORTRAIT_DOWN: converts to 180 degrees.
   *   <li>LANDSCAPE_RIGHT: converts to 270 degrees.
   * </ul>
   *
   * @param orientation The {@link PlatformChannel.DeviceOrientation} value that is to be converted
   *     into degrees.
   * @return The device's orientation in degrees.
   */
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

    if (isFrontFacing) {
      angle *= -1;
    }

    return (angle + sensorOrientation + 360) % 360;
  }

  private void startSensorListener() {
    if (orientationEventListener != null) {
      return;
    }
    orientationEventListener =
        new OrientationEventListener(activity, SensorManager.SENSOR_DELAY_NORMAL) {
          @Override
          public void onOrientationChanged(int angle) {
            handleSensorOrientationChange(angle);
          }
        };
    if (orientationEventListener.canDetectOrientation()) {
      orientationEventListener.enable();
    }
  }

  private void startUIListener() {
    if (broadcastReceiver != null) {
      return;
    }
    broadcastReceiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            handleUIOrientationChange();
          }
        };
    activity.registerReceiver(broadcastReceiver, orientationIntentFilter);
    broadcastReceiver.onReceive(activity, null);
  }

  /**
   * Handles orientation changes based on information from the device's sensors.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @param angle of the current orientation.
   */
  @VisibleForTesting
  void handleSensorOrientationChange(int angle) {
    if (!isAccelerometerRotationLocked()) {
      PlatformChannel.DeviceOrientation orientation = calculateSensorOrientation(angle);
      lastOrientation = handleOrientationChange(orientation, lastOrientation, messenger);
    }
  }

  /**
   * Handles orientation changes based on change events triggered by the OrientationIntentFilter.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  void handleUIOrientationChange() {
    if (isAccelerometerRotationLocked()) {
      PlatformChannel.DeviceOrientation orientation = getUIOrientation();
      lastOrientation = handleOrientationChange(orientation, lastOrientation, messenger);
    }
  }

  /**
   * Handles orientation changes coming from either the device's sensors or the
   * OrientationIntentFilter.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  static DeviceOrientation handleOrientationChange(
      DeviceOrientation newOrientation,
      DeviceOrientation previousOrientation,
      DartMessenger messenger) {
    if (!newOrientation.equals(previousOrientation)) {
      messenger.sendDeviceOrientationChangeEvent(newOrientation);
    }

    return newOrientation;
  }

  private void stopSensorListener() {
    if (orientationEventListener == null) {
      return;
    }
    orientationEventListener.disable();
    orientationEventListener = null;
  }

  private void stopUIListener() {
    if (broadcastReceiver == null) {
      return;
    }
    activity.unregisterReceiver(broadcastReceiver);
    broadcastReceiver = null;
  }

  private boolean isAccelerometerRotationLocked() {
    return android.provider.Settings.System.getInt(
            activity.getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0)
        != 1;
  }

  /**
   * Gets the current user interface orientation.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return The current user interface orientation.
   */
  @VisibleForTesting
  PlatformChannel.DeviceOrientation getUIOrientation() {
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

  /**
   * Calculates the sensor orientation based on the supplied angle.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @param angle Orientation angle.
   * @return The sensor orientation based on the supplied angle.
   */
  @VisibleForTesting
  PlatformChannel.DeviceOrientation calculateSensorOrientation(int angle) {
    final int tolerance = 45;
    angle += tolerance;

    // Orientation is 0 in the default orientation mode. This is portrait-mode for phones
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

  /**
   * Gets the default orientation of the device.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return The default orientation of the device.
   */
  @VisibleForTesting
  int getDeviceDefaultOrientation() {
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

  /**
   * Gets an instance of the Android {@link android.view.Display}.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return An instance of the Android {@link android.view.Display}.
   */
  @SuppressWarnings("deprecation")
  @VisibleForTesting
  Display getDisplay() {
    return ((WindowManager) activity.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
  }
}
