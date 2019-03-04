part of firebase_remote_config;

/// ValueSource defines the possible sources of a config parameter value.
enum ValueSource { valueStatic, valueDefault, valueRemote }

/// RemoteConfigValue encapsulates the value and source of a Remote Config
/// parameter.
class RemoteConfigValue {
  RemoteConfigValue._(this._value, this._source);

  List<int> _value;
  ValueSource _source;

  /// Indicates at which source this value came from.
  ValueSource get source => _source == ValueSource.valueDefault
      ? ValueSource.valueDefault
      : ValueSource.valueRemote;

  /// Decode value to string.
  String asString() {
    return _value != null
        ? const Utf8Codec().decode(_value)
        : RemoteConfig.defaultValueForString;
  }

  /// Decode value to int.
  int asInt() {
    if (_value != null) {
      final String strValue = const Utf8Codec().decode(_value);
      final int intValue =
          int.tryParse(strValue) ?? RemoteConfig.defaultValueForInt;
      return intValue;
    } else {
      return RemoteConfig.defaultValueForInt;
    }
  }

  /// Decode value to double.
  double asDouble() {
    if (_value != null) {
      final String strValue = const Utf8Codec().decode(_value);
      final double doubleValue =
          double.tryParse(strValue) ?? RemoteConfig.defaultValueForDouble;
      return doubleValue;
    } else {
      return RemoteConfig.defaultValueForDouble;
    }
  }

  /// Decode value to bool.
  bool asBool() {
    if (_value != null) {
      final String strValue = const Utf8Codec().decode(_value);
      return strValue.toLowerCase() == 'true';
    } else {
      return RemoteConfig.defaultValueForBool;
    }
  }
}
