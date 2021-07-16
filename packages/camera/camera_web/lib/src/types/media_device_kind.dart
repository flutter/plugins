/// A kind of a media device.
/// https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/kind
abstract class MediaDeviceKind {
  /// A video input media device kind.
  static const videoInput = 'videoinput';

  /// An audio input media device kind.
  static const audioInput = 'audioinput';

  /// An audio output media device kind.
  static const audioOutput = 'audiooutput';
}
