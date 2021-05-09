// ignore_for_file: public_member_api_docs
import 'dart:js_util' as js_util;

class MediaTrackCapabilities {
  final DoubleRange? aspectRatio;
  final List<bool>? autoGainControl;
  final DoubleRange? channelCount;
  final String? deviceId;
  final List<bool>? echoCancellation;
  final List<String>? facingMode;
  final DoubleRange? frameRate;
  final String? groupId;
  final DoubleRange? height;
  final DoubleRange? latency;
  final List<bool>? noiseSuppression;
  final List<String>? resizeMode;
  final DoubleRange? sampleRate;
  final DoubleRange? sampleSize;
  final DoubleRange? width;
  final DoubleRangeStep? brightness;
  final DoubleRangeStep? colorTemperature;
  final DoubleRangeStep? contrast;
  final DoubleRangeStep? exposureTime;
  final DoubleRangeStep? saturation;
  final DoubleRangeStep? sharpness;
  final List<String>? exposureMode;
  final List<String>? whiteBalanceMode;
  final DoubleRangeStep? focusDistance;
  final List<String>? focusMode;
  final DoubleRangeStep? zoom;

  const MediaTrackCapabilities(
      this.aspectRatio,
      this.autoGainControl,
      this.channelCount,
      this.deviceId,
      this.echoCancellation,
      this.facingMode,
      this.frameRate,
      this.groupId,
      this.height,
      this.latency,
      this.noiseSuppression,
      this.resizeMode,
      this.sampleRate,
      this.sampleSize,
      this.width,
      this.brightness,
      this.colorTemperature,
      this.contrast,
      this.exposureTime,
      this.saturation,
      this.sharpness,
      this.exposureMode,
      this.whiteBalanceMode,
      this.focusDistance,
      this.focusMode,
      this.zoom);

  static MediaTrackCapabilities fromObject(Map<dynamic, dynamic> obj) {
    final aspectRatio = DoubleRange.decode(obj, 'aspectRatio');
    final autoGainControl = nullOrType<List<bool>>(obj, 'autoGainControl');
    final channelCount = DoubleRange.decode(obj, 'channelCount');
    final deviceId = nullOrType<String>(obj, 'deviceId');
    final echoCancellation = nullOrType<List<bool>>(obj, 'echoCancellation');
    final facingMode = nullOrType<List<dynamic>>(obj, 'facingMode');
    final frameRate = DoubleRange.decode(obj, 'frameRate');
    final groupId = nullOrType<String>(obj, 'groupId');
    final height = DoubleRange.decode(obj, 'height');
    final latency = DoubleRange.decode(obj, 'latency');
    final noiseSuppression = nullOrType<List<bool>>(obj, 'noiseSuppression');
    final resizeMode = nullOrType<List<dynamic>>(obj, 'resizeMode');
    final sampleRate = DoubleRange.decode(obj, 'sampleRate');
    final sampleSize = DoubleRange.decode(obj, 'sampleSize');
    final width = DoubleRange.decode(obj, 'width');
    final brightness = DoubleRangeStep.decode(obj, 'brightness');
    final colorTemperature = DoubleRangeStep.decode(obj, 'colorTemperature');

    final contrast = DoubleRangeStep.decode(obj, 'contrast');
    final exposureTime = DoubleRangeStep.decode(obj, 'exposureTime');
    final saturation = DoubleRangeStep.decode(obj, 'saturation');
    final sharpness = DoubleRangeStep.decode(obj, 'sharpness');
    final exposureMode = nullOrType<List<dynamic>>(obj, 'exposureMode');
    final whiteBalanceMode = nullOrType<List<dynamic>>(obj, 'whiteBalanceMode');
    final focusDistance = DoubleRangeStep.decode(obj, 'focusDistance');
    final focusMode = nullOrType<List<dynamic>>(obj, 'focusMode');
    final zoom = nullOrType<DoubleRangeStep>(obj, 'zoom');

    return MediaTrackCapabilities(
        aspectRatio,
        autoGainControl,
        channelCount,
        deviceId,
        echoCancellation,
        facingMode?.cast<String>(),
        frameRate,
        groupId,
        height,
        latency,
        noiseSuppression,
        resizeMode?.cast<String>(),
        sampleRate,
        sampleSize,
        width,
        brightness,
        colorTemperature,
        contrast,
        exposureTime,
        saturation,
        sharpness,
        exposureMode?.cast<String>(),
        whiteBalanceMode?.cast<String>(),
        focusDistance,
        focusMode?.cast<String>(), zoom);
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    if (aspectRatio != null) {
      buffer.writeln('AspectRatio: $aspectRatio');
    }
    if (autoGainControl != null) {
      buffer.writeln('AutoGainControl: $autoGainControl');
    }
    if (channelCount != null) {
      buffer.writeln('ChannelCount: $channelCount');
    }
    if (deviceId != null) {
      buffer.writeln('DeviceId: $deviceId');
    }
    if (echoCancellation != null) {
      buffer.writeln('EchoCancellation: $echoCancellation');
    }
    if (facingMode != null) {
      buffer.writeln('FacingMode: $facingMode');
    }
    if (frameRate != null) {
      buffer.writeln('FrameRate: $frameRate');
    }
    if (noiseSuppression != null) {
      buffer.writeln('NoiseSuppression: $noiseSuppression');
    }
    if (height != null) {
      buffer.writeln('Height: $height');
    }
    if (latency != null) {
      buffer.writeln('Latency: $latency');
    }
    if (resizeMode != null) {
      buffer.writeln('ResizeMode: $resizeMode');
    }
    if (sampleRate != null) {
      buffer.writeln('SampleRate: $sampleRate');
    }
    if (sampleSize != null) {
      buffer.writeln('SampleSize: $sampleSize');
    }
    if (width != null) {
      buffer.writeln('Width: $width');
    }
    if (brightness != null) {
      buffer.writeln('Brightness: $brightness');
    }
    if (colorTemperature != null) {
      buffer.writeln('ColorTemperature: $colorTemperature');
    }

    if (contrast != null) {
      buffer.writeln('Contrast: $contrast');
    }
    if (exposureTime != null) {
      buffer.writeln('ExposureTime: $exposureTime');
    }
    if (saturation != null) {
      buffer.writeln('Saturation: $saturation');
    }
    if (sharpness != null) {
      buffer.writeln('Sharpness: $sharpness');
    }
    if (exposureMode != null) {
      buffer.writeln('ExposureMode: $exposureMode');
    }
    if (whiteBalanceMode != null) {
      buffer.writeln('WhiteBalanceMode: $whiteBalanceMode');
    }
    if (focusDistance != null) {
      buffer.writeln('FocusDistance: $focusDistance');
    }
    if (focusMode != null) {
      buffer.writeln('FocusMode: $focusMode');
    }
    if (zoom != null) {
      buffer.writeln('Zoom: $zoom');
    }
    return buffer.toString();
  }
}

class DoubleRange {
  final num max;
  final num min;

  const DoubleRange(this.max, this.min);

  DoubleRange.fromObject(dynamic obj)
      : max = js_util.getProperty(obj, 'max'),
        min = js_util.getProperty(obj, 'min');

  static DoubleRange? decode(dynamic obj, String key) {
    final val = obj[key];
    if (val == null) {
      return null;
    }
    return DoubleRange.fromObject(val);
  }

  @override
  String toString() => 'DoubleRange($max - $min)';
}

class DoubleRangeStep {
  final num max;
  final num min;
  final num step;

  const DoubleRangeStep(this.max, this.min, this.step);

  DoubleRangeStep.fromObject(dynamic obj)
      : max = js_util.getProperty(obj, 'max'),
        min = js_util.getProperty(obj, 'min'),
        step = js_util.getProperty(obj, 'step');

  static DoubleRangeStep? decode(dynamic obj, String key) {
    final val = obj[key];
    if (val == null) {
      return null;
    }
    return DoubleRangeStep.fromObject(val);
  }

  @override
  String toString() => 'DoubleRangeStep($max - $min : $step)';
}

T? nullOrType<T>(dynamic obj, String key) {
  final val = obj[key];
  if (val == null) {
    return null;
  }
  return val as T;
}
