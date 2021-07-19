/// Metadata used along the camera description
/// to store additional web-specific camera details.
class CameraMetadata {
  /// Creates a new instance of [CameraMetadata]
  /// with the given [deviceId] and [facingMode].
  const CameraMetadata({required this.deviceId, required this.facingMode});

  /// Uniquely identifies the camera device.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/deviceId
  final String deviceId;

  /// Describes the direction the camera is facing towards.
  /// May be `user`, `environment`, `left`, `right`
  /// or null if the facing mode is not available.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackSettings/facingMode
  final String? facingMode;
}
