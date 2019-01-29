import 'dart:async';

import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/accelerometer');

const EventChannel _userAccelerometerGravityEventChannel =
    EventChannel('plugins.flutter.io/sensors/user_accel_gravity');

const EventChannel _gyroscopeEventChannel =
    EventChannel('plugins.flutter.io/sensors/gyroscope');

class AccelerometerEvent {
  AccelerometerEvent(this.x, this.y, this.z);

  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  final double z;

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class GyroscopeEvent {
  GyroscopeEvent(this.x, this.y, this.z);

  /// Rate of rotation around the x axis measured in rad/s.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  final double z;

  @override
  String toString() => '[GyroscopeEvent (x: $x, y: $y, z: $z)]';
}

class UserAccelerometerEvent {
  UserAccelerometerEvent(this.x, this.y, this.z);

  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  final double z;

  @override
  String toString() => '[UserAccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class GravityEvent {
  GravityEvent(this.x, this.y, this.z);

  /// Gravity force along the x axis measured in m/s^2.
  final double x;

  /// Gravity force along the y axis measured in m/s^2.
  final double y;

  /// Gravity force along the z axis measured in m/s^2.
  final double z;

  @override
  String toString() => '[GravityEvent (x: $x, y: $y, z: $z)]';
}

AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return AccelerometerEvent(list[0], list[1], list[2]);
}

UserAccelerometerEvent _listToUserAccelerometerEvent(List<double> list) {
  return UserAccelerometerEvent(list[0], list[1], list[2]);
}

GravityEvent _listToGravityEvent(List<double> list) {
  return GravityEvent(list[3], list[4], list[5]);
}

GyroscopeEvent _listToGyroscopeEvent(List<double> list) {
  return GyroscopeEvent(list[0], list[1], list[2]);
}

Stream<AccelerometerEvent> _accelerometerEvents;
Stream<GyroscopeEvent> _gyroscopeEvents;
Stream<List<double>> _userAccelerometerGravityEvents;
Stream<UserAccelerometerEvent> _userAccelerometerEvents;
Stream<GravityEvent> _gravityEvents;

/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent> get accelerometerEvents {
  if (_accelerometerEvents == null) {
    _accelerometerEvents = _accelerometerEventChannel
        .receiveBroadcastStream()
        .map(
            (dynamic event) => _listToAccelerometerEvent(event.cast<double>()));
  }
  return _accelerometerEvents;
}

/// A broadcast stream of events from the device gyroscope.
Stream<GyroscopeEvent> get gyroscopeEvents {
  if (_gyroscopeEvents == null) {
    _gyroscopeEvents = _gyroscopeEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToGyroscopeEvent(event.cast<double>()));
  }
  return _gyroscopeEvents;
}

Stream<List<double>> get _userAccelerometerAndGravityEvents {
  if (_userAccelerometerGravityEvents == null) {
    _userAccelerometerGravityEvents = _userAccelerometerGravityEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event.cast<double>());
  }
  return _userAccelerometerGravityEvents;
}

/// Events from the device accelerometer with gravity removed.
Stream<UserAccelerometerEvent> get userAccelerometerEvents {
  if (_userAccelerometerEvents == null) {
    _userAccelerometerEvents = _userAccelerometerAndGravityEvents
        .map((List<double> data) => _listToUserAccelerometerEvent(data));
  }
  return _userAccelerometerEvents;
}

/// Events from the device accelerometer, gravity only.
Stream<GravityEvent> get gravityEvents {
  if (_gravityEvents == null) {
    _gravityEvents =
        _userAccelerometerAndGravityEvents.map((List<double> data) {
      return _listToGravityEvent(data);
    });
  }
  return _gravityEvents;
}
