// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sensors;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SensorsPlugin */
public class SensorsPlugin implements FlutterPlugin {
  private static final String ACCELEROMETER_CHANNEL_NAME =
      "plugins.flutter.io/sensors/accelerometer";
  private static final String GYROSCOPE_CHANNEL_NAME = "plugins.flutter.io/sensors/gyroscope";
  private static final String USER_ACCELEROMETER_CHANNEL_NAME =
      "plugins.flutter.io/sensors/user_accel";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {

    final EventChannel accelerometerChannel =
        new EventChannel(registrar.messenger(), ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl accelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager)
                registrar.context().getSystemService(registrar.context().SENSOR_SERVICE),
            Sensor.TYPE_ACCELEROMETER);
    accelerometerChannel.setStreamHandler(accelerationStreamHandler);

    final EventChannel userAccelChannel =
        new EventChannel(registrar.messenger(), USER_ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl linearAccelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager)
                registrar.context().getSystemService(registrar.context().SENSOR_SERVICE),
            Sensor.TYPE_LINEAR_ACCELERATION);
    userAccelChannel.setStreamHandler(linearAccelerationStreamHandler);

    final EventChannel gyroscopeChannel =
        new EventChannel(registrar.messenger(), GYROSCOPE_CHANNEL_NAME);
    final StreamHandlerImpl gyroScopeStreamHandler =
        new StreamHandlerImpl(
            (SensorManager)
                registrar.context().getSystemService(registrar.context().SENSOR_SERVICE),
            Sensor.TYPE_GYROSCOPE);
    gyroscopeChannel.setStreamHandler(gyroScopeStreamHandler);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    Context context = binding.getApplicationContext();
    final EventChannel accelerometerChannel =
        new EventChannel(binding.getFlutterEngine().getDartExecutor(), ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl accelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(context.SENSOR_SERVICE),
            Sensor.TYPE_ACCELEROMETER);
    accelerometerChannel.setStreamHandler(accelerationStreamHandler);

    final EventChannel userAccelChannel =
        new EventChannel(
            binding.getFlutterEngine().getDartExecutor(), USER_ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl linearAccelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(context.SENSOR_SERVICE),
            Sensor.TYPE_LINEAR_ACCELERATION);
    userAccelChannel.setStreamHandler(linearAccelerationStreamHandler);

    final EventChannel gyroscopeChannel =
        new EventChannel(binding.getFlutterEngine().getDartExecutor(), GYROSCOPE_CHANNEL_NAME);
    final StreamHandlerImpl gyroScopeStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(context.SENSOR_SERVICE),
            Sensor.TYPE_GYROSCOPE);
    gyroscopeChannel.setStreamHandler(gyroScopeStreamHandler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
