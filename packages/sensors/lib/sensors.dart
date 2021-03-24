// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/accelerometer');

const EventChannel _userAccelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/user_accel');

const EventChannel _gyroscopeEventChannel =
    EventChannel('plugins.flutter.io/sensors/gyroscope');

/// Discrete reading from an accelerometer. Accelerometers measure the velocity
/// of the device. Note that these readings include the effects of gravity. Put
/// simply, you can use accelerometer readings to tell if the device is moving in
/// a particular direction.
class AccelerometerEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  AccelerometerEvent(this.x, this.y, this.z);

  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving to the right and negative mean it is moving to the left.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving towards the sky and negative mean it is moving towards
  /// the ground.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  ///
  /// This uses a right-handed coordinate system. So when the device is held
  /// upright and facing the user, positive values mean the device is moving
  /// towards the user and negative mean it is moving away from them.
  final double z;

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}

/// Discrete reading from a gyroscope. Gyroscopes measure the rate or rotation of
/// the device in 3D space.
class GyroscopeEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  GyroscopeEvent(this.x, this.y, this.z);

  /// Rate of rotation around the x axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "pitch". The top of the device will tilt towards or away from the
  /// user as this value changes.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "yaw". The lengthwise edge of the device will rotate towards or away from
  /// the user as this value changes.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "roll". When this changes the face of the device should remain facing
  /// forward, but the orientation will change from portrait to landscape and so
  /// on.
  final double z;

  @override
  String toString() => '[GyroscopeEvent (x: $x, y: $y, z: $z)]';
}

/// Like [AccelerometerEvent], this is a discrete reading from an accelerometer
/// and measures the velocity of the device. However, unlike
/// [AccelerometerEvent], this event does not include the effects of gravity.
class UserAccelerometerEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  UserAccelerometerEvent(this.x, this.y, this.z);

  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving to the right and negative mean it is moving to the left.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving towards the sky and negative mean it is moving towards
  /// the ground.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  ///
  /// This uses a right-handed coordinate system. So when the device is held
  /// upright and facing the user, positive values mean the device is moving
  /// towards the user and negative mean it is moving away from them.
  final double z;

  @override
  String toString() => '[UserAccelerometerEvent (x: $x, y: $y, z: $z)]';
}

AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return AccelerometerEvent(list[0], list[1], list[2]);
}

UserAccelerometerEvent _listToUserAccelerometerEvent(List<double> list) {
  return UserAccelerometerEvent(list[0], list[1], list[2]);
}

GyroscopeEvent _listToGyroscopeEvent(List<double> list) {
  return GyroscopeEvent(list[0], list[1], list[2]);
}

Stream<AccelerometerEvent>? _accelerometerEvents;
Stream<GyroscopeEvent>? _gyroscopeEvents;
Stream<UserAccelerometerEvent>? _userAccelerometerEvents;

/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent> get accelerometerEvents {
  Stream<AccelerometerEvent>? accelerometerEvents = _accelerometerEvents;
  if (accelerometerEvents == null) {
    accelerometerEvents =
        _accelerometerEventChannel.receiveBroadcastStream().map(
              (dynamic event) =>
                  _listToAccelerometerEvent(event.cast<double>()),
            );
    _accelerometerEvents = accelerometerEvents;
  }

  return accelerometerEvents;
}

/// A broadcast stream of events from the device gyroscope.
Stream<GyroscopeEvent> get gyroscopeEvents {
  Stream<GyroscopeEvent>? gyroscopeEvents = _gyroscopeEvents;
  if (gyroscopeEvents == null) {
    gyroscopeEvents = _gyroscopeEventChannel.receiveBroadcastStream().map(
          (dynamic event) => _listToGyroscopeEvent(event.cast<double>()),
        );
    _gyroscopeEvents = gyroscopeEvents;
  }

  return gyroscopeEvents;
}

/// Events from the device accelerometer with gravity removed.
Stream<UserAccelerometerEvent> get userAccelerometerEvents {
  Stream<UserAccelerometerEvent>? userAccelerometerEvents =
      _userAccelerometerEvents;
  if (userAccelerometerEvents == null) {
    userAccelerometerEvents =
        _userAccelerometerEventChannel.receiveBroadcastStream().map(
              (dynamic event) =>
                  _listToUserAccelerometerEvent(event.cast<double>()),
            );
    _userAccelerometerEvents = userAccelerometerEvents;
  }

  return userAccelerometerEvents;
}
