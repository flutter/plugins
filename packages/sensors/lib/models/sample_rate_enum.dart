part of sensors;

enum SampleRate {
  /// Android: Maps to the sample rate of SensorManager.SENSOR_DELAY_NORMAL (15 events per second).
  /// iOS: Maps to a update interval of 1/15 (15 events per second).
  /// Constitutes the default value.
  low,

  /// Android: Maps to the sample rate of SensorManager.SENSOR_DELAY_GAME (50 events per second).
  /// iOS: Maps to a update interval of 1/50 (50 events per second).
  medium,

  /// Android: Maps to the sample rate of SensorManager.SENSOR_DELAY_FASTEST (120 events per second).
  /// iOS: Maps to the maximum update interval of 1/100 (100 events per second).
  high
}
