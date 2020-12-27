package io.flutter.plugins.camera.types;

// Mirrors flash_mode.dart
public enum FlashMode {
  off,
  auto,
  always,
  torch;

  public static FlashMode getValueForString(String modeStr) {
    try {
      return valueOf(modeStr);
    } catch (IllegalArgumentException | NullPointerException e) {
      return null;
    }
  }
}
