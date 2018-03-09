part of firebase_remote_config;

enum ValueSource {
  valueStatic,
  valueDefault,
  valueRemote
}

class RemoteConfigValue {

  dynamic _value;
  ValueSource _source;

  RemoteConfigValue._(this._value, this._source);

  ValueSource get source => _source == ValueSource.valueDefault ? ValueSource.valueDefault : ValueSource.valueRemote;

  String asString() {
    return _value != null ? UTF8.decode(_value) : RemoteConfig.defaultValueForString;
  }

  int asInt() {
    if (_value != null) {
      final String strValue = UTF8.decode(_value);
      final int intValue = int.parse(strValue, onError: (String source) => RemoteConfig.defaultValueForInt);
      return intValue;
    } else {
      return RemoteConfig.defaultValueForInt;
    }
  }

  double asDouble() {
    if (_value != null) {
      final String strValue = UTF8.decode(_value);
      final double doubleValue = double.parse(strValue, (String source) => RemoteConfig.defaultValueForDouble);
      return doubleValue;
    } else {
      return RemoteConfig.defaultValueForDouble;
    }
  }

  bool asBool() {
    if (_value != null) {
      final String strValue = UTF8.decode(_value);
      return strValue.toLowerCase() == 'true';
    } else {
      return RemoteConfig.defaultValueForBool;
    }
  }

}