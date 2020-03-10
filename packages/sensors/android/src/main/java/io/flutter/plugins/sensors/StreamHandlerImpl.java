// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sensors;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import io.flutter.plugin.common.EventChannel;
import java.util.Arrays;

class StreamHandlerImpl implements EventChannel.StreamHandler {

  private SensorEventListener sensorEventListener;
  private final SensorManager sensorManager;
  private final Sensor[] sensors;
  private final double[] values;

  StreamHandlerImpl(SensorManager sensorManager, int... sensorTypes) {
    this.sensorManager = sensorManager;
    sensors = new Sensor[sensorTypes.length];
    for (int i = 0; i < sensorTypes.length; ++i) {
      sensors[i] = sensorManager.getDefaultSensor(sensorTypes[i]);
    }
    values = new double[sensorTypes.length * 3];
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sensorEventListener = createSensorEventListener(events);
    for (Sensor sensor : sensors) {
      sensorManager.registerListener(sensorEventListener, sensor, SensorManager.SENSOR_DELAY_GAME);
    }
  }

  @Override
  public void onCancel(Object arguments) {
    sensorManager.unregisterListener(sensorEventListener);
  }

  private SensorEventListener createSensorEventListener(final EventChannel.EventSink events) {
    return new SensorEventListener() {
      @Override
      public void onAccuracyChanged(Sensor sensor, int accuracy) {}

      @Override
      public void onSensorChanged(SensorEvent event) {
        if (event.values.length >= 3) {
          int offset = -1;
          for (int i = 0; i < sensors.length; ++i) {
            if (sensors[i].equals(event.sensor)) {
              offset = i * 3;
              break;
            }
          }
          if (offset >= 0) {
            for (int i = 0; i < 3; i++) {
              values[offset + i] = event.values[i];
            }
            events.success(Arrays.copyOf(values, values.length));
          }
        }
      }
    };
  }
}
