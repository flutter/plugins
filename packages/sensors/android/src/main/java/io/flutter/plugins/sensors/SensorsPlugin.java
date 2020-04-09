// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sensors;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SensorsPlugin */
public class SensorsPlugin implements FlutterPlugin {
  private static final String ACCELEROMETER_CHANNEL_NAME =
      "plugins.flutter.io/sensors/accelerometer";
  private static final String GYROSCOPE_CHANNEL_NAME = "plugins.flutter.io/sensors/gyroscope";
  private static final String USER_ACCELEROMETER_CHANNEL_NAME =
      "plugins.flutter.io/sensors/user_accel";

  private EventChannel accelerometerChannel;
  private EventChannel userAccelChannel;
  private EventChannel gyroscopeChannel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    SensorsPlugin plugin = new SensorsPlugin();
    plugin.setupEventChannels(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final Context context = binding.getApplicationContext();
    setupEventChannels(context, binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownEventChannels();
  }

  private void setupEventChannels(Context context, BinaryMessenger messenger) {
    accelerometerChannel = new EventChannel(messenger, ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl accelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(context.SENSOR_SERVICE),
            Sensor.TYPE_ACCELEROMETER);
    accelerometerChannel.setStreamHandler(accelerationStreamHandler);

    userAccelChannel = new EventChannel(messenger, USER_ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl linearAccelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(context.SENSOR_SERVICE),
            Sensor.TYPE_LINEAR_ACCELERATION);
    userAccelChannel.setStreamHandler(linearAccelerationStreamHandler);

    gyroscopeChannel = new EventChannel(messenger, GYROSCOPE_CHANNEL_NAME);
    final StreamHandlerImpl gyroScopeStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(context.SENSOR_SERVICE),
            Sensor.TYPE_GYROSCOPE);
    gyroscopeChannel.setStreamHandler(gyroScopeStreamHandler);
  }

  private void teardownEventChannels() {
    accelerometerChannel.setStreamHandler(null);
    userAccelChannel.setStreamHandler(null);
    gyroscopeChannel.setStreamHandler(null);
  }
}
