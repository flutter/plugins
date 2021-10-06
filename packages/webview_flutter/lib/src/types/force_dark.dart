///A class used to indicate the force dark mode.
///
///available only on Android 29+
class ForceDark {
  final int _value;

  const ForceDark._internal(this._value);

  static final Set<ForceDark> values = [
    ForceDark.OFF,
    ForceDark.AUTO,
    ForceDark.ON,
  ].toSet();

  ///Converts integer value to ForceDark type
  static ForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return ForceDark.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets integer value of ForceDark type
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "FORCE_DARK_AUTO";
      case 2:
        return "FORCE_DARK_ON";
      case 0:
      default:
        return "FORCE_DARK_OFF";
    }
  }

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless
  ///of whether native views are being automatically darkened.
  static const OFF = ForceDark._internal(0);

  ///Enable force dark dependent on the state of the WebView parent view.
  static const AUTO = ForceDark._internal(1);

  ///Unconditionally enable force dark. In this mode WebView content
  ///will always be rendered so as to emulate a dark theme.
  static const ON = ForceDark._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
