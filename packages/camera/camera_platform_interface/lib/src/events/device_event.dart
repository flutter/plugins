import 'package:camera_platform_interface/src/utils/utils.dart';
import 'package:flutter/services.dart';

/// Generic Event coming from the native side of Camera, that are not related to a specific camera module.
///
/// This class is used as a base class for all the events that might be
/// triggered from a device, but it is never used directly as an event type.
///
/// Do NOT instantiate new events like `DeviceEvent(cameraId)` directly,
/// use a specific class instead:
///
/// Do `class NewEvent extend DeviceEvent` when creating your own events.
/// See below for examples: `DeviceOrientationChangedEvent`...
/// These events are more semantic and more pleasant to use than raw generics.
/// They can be (and in fact, are) filtered by the `instanceof`-operator.
abstract class DeviceEvent {}

/// An event fired whenever.
class DeviceOrientationChangedEvent extends DeviceEvent {
  /// The new orientation the device
  final DeviceOrientation orientation;

  /// Build a new orientation changed event.
  DeviceOrientationChangedEvent(this.orientation);

  /// Converts the supplied [Map] to an instance of the [DeviceOrientationChangedEvent]
  /// class.
  DeviceOrientationChangedEvent.fromJson(Map<String, dynamic> json)
      : orientation = deserializeDeviceOrientation(json['orientation']);

  /// Converts the [DeviceOrientationChangedEvent] instance into a [Map] instance that
  /// can be serialized to JSON.
  Map<String, dynamic> toJson() => {
        'orientation': serializeDeviceOrientation(orientation),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceOrientationChangedEvent &&
          runtimeType == other.runtimeType &&
          orientation == other.orientation;

  @override
  int get hashCode => orientation.hashCode;
}
