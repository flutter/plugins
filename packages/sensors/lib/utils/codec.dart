part of sensors;

class Codec {
  static String encodeSensorsSampleRate(SampleRate sampleRate) {
    return sampleRate.toString().split('.').last;
  }
}
