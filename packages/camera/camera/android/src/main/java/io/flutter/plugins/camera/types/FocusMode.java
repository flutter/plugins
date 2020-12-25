package io.flutter.plugins.camera.types;

// Mirrors focus_mode.dart
public enum FocusMode {
  continuous("continuous"),
  auto("auto");

  private final String strValue;

  FocusMode(String strValue) {
    this.strValue = strValue;
  }

  public static FocusMode getValueForString(String modeStr) {
    for (FocusMode value : values()) {
      if (value.strValue.equals(modeStr)) return value;
    }
    return null;
  }

  @Override
  public String toString() {
    return strValue;
  }
}
