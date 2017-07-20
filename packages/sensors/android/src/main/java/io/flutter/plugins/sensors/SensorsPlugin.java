// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sensors;

import android.app.Activity;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SensorsPlugin */
public class SensorsPlugin implements EventChannel.StreamHandler {
  private static final String ACCELEROMETER_CHANNEL_NAME = "plugins.flutter.io/accelerometer";
  private static final String GYROSCOPE_CHANNEL_NAME = "plugins.flutter.io/gyroscope";

  /** Plugin registration. */
  public static SensorsPlugin registerWith(Registrar registrar) {
    final EventChannel accelerometerChannel =
        new EventChannel(registrar.messenger(), ACCELEROMETER_CHANNEL_NAME);
    accelerometerChannel.setStreamHandler(
        new SensorsPlugin(registrar.activity(), Sensor.TYPE_ACCELEROMETER));

    final EventChannel gyroscopeChannel =
        new EventChannel(registrar.messenger(), GYROSCOPE_CHANNEL_NAME);
    // To fit with the general plugin pattern this method needs to return an instance of the
    // registered plugin. Neither version of the plugin requires any further initialization
    // so just return this version. If further initialization will be needed in the future,
    // this plugin should be split into two classes with separate registerWith methods.
    final SensorsPlugin instance = new SensorsPlugin(registrar.activity(), Sensor.TYPE_GYROSCOPE);
    gyroscopeChannel.setStreamHandler(instance);
      
    return instance;
  }

  private SensorEventListener sensorEventListener;
  private final SensorManager sensorManager;
  private final Sensor sensor;

  private SensorsPlugin(Activity activity, int sensorType) {
    sensorManager = (SensorManager) activity.getSystemService(activity.SENSOR_SERVICE);
    sensor = sensorManager.getDefaultSensor(sensorType);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sensorEventListener = createSensorEventListener(events);
    sensorManager.registerListener(sensorEventListener, sensor, sensorManager.SENSOR_DELAY_NORMAL);
  }

  @Override
  public void onCancel(Object arguments) {
    sensorManager.unregisterListener(sensorEventListener);
  }

  SensorEventListener createSensorEventListener(final EventChannel.EventSink events) {
    return new SensorEventListener() {
      @Override
      public void onAccuracyChanged(Sensor sensor, int accuracy) {}

      @Override
      public void onSensorChanged(SensorEvent event) {
        double[] sensorValues = new double[event.values.length];
        for (int i = 0; i < event.values.length; i++) {
          sensorValues[i] = event.values[i];
        }
        events.success(sensorValues);
      }
    };
  }
}
