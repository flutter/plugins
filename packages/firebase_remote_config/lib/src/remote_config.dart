part of firebase_remote_config;

enum LastFetchStatus {
  success,
  failure,
  throttled,
  noFetchYet
}

class RemoteConfig {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/firebase_remote_config');

  static const String defaultValueForString = '';
  static const int defaultValueForInt = 0;
  static const double defaultValueForDouble = 0.0;
  static const bool defaultValueForBool = false;

  static const String fetchFailedThrottled = 'FETCH_FAILED_THROTTLED';

  Map<String, RemoteConfigValue> _parameters;

  DateTime _lastFetchTime;
  LastFetchStatus _lastFetchStatus;
  RemoteConfigSettings _remoteConfigSettings;

  RemoteConfig._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'UpdateFetch':
          _lastFetchTime = new DateTime.fromMillisecondsSinceEpoch(call.arguments['LAST_FETCH_TIME']);
          _lastFetchStatus = LastFetchStatus.values[call.arguments['LAST_FETCH_STATUS']];
          return null;
        default:
          throw new MissingPluginException(
            '${call.method} method not implemented on the Dart side.',
          );
      }
    });
  }

  DateTime get lastFetchTime => _lastFetchTime;
  LastFetchStatus get lastFetchStatus => _lastFetchStatus;
  RemoteConfigSettings get remoteConfigSettings => _remoteConfigSettings;

  /// Gets the instance of RemoteConfig for the default Firebase app.
  static Future<RemoteConfig> get instance async {
    final Map<String, dynamic> properties = await _channel.invokeMethod(
      'RemoteConfig#instance'
    );
    final RemoteConfig remoteConfig = new RemoteConfig._();
    remoteConfig._lastFetchTime = new DateTime.fromMillisecondsSinceEpoch(properties['LAST_FETCH_TIME']);
    remoteConfig._lastFetchStatus = LastFetchStatus.values[properties['LAST_FETCH_STATUS']];
    final RemoteConfigSettings remoteConfigSettings = new RemoteConfigSettings();
    remoteConfigSettings.debugMode = properties['IN_DEBUG_MODE'];
    remoteConfig._remoteConfigSettings = remoteConfigSettings;
    remoteConfig._parameters = <String, RemoteConfigValue>{};
    return remoteConfig;
  }

  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) async {
    await _channel.invokeMethod(
      'RemoteConfig#setConfigSettings',
      <String, dynamic> {
        'debugMode': remoteConfigSettings.debugMode,
      }
    );
    _remoteConfigSettings = remoteConfigSettings;
    return new Future<void>.value();
  }

  Future<void> fetch({int expiration: 43200}) async {
    final Map<String, dynamic> properties = await _channel.invokeMethod(
      'RemoteConfig#fetch',
      <String, dynamic>{
        'expiration': expiration
      }
    );
    _lastFetchTime = new DateTime.fromMillisecondsSinceEpoch(properties['LAST_FETCH_TIME']);
    _lastFetchStatus = LastFetchStatus.values[properties['LAST_FETCH_STATUS']];
    return new Future<void>.value();
  }

  Future<void> activate() async {
    final Map<String, dynamic> parameters  = await _channel.invokeMethod(
      'RemoteConfig#activate'
    );
    _parameters = <String, RemoteConfigValue>{};
    parameters.forEach((String key, dynamic value) {
      final ValueSource valueSource = ValueSource.values[value['source']];
      final RemoteConfigValue remoteConfigValue = new RemoteConfigValue._(value['value'], valueSource);
      _parameters[key] = remoteConfigValue;
    });
    return new Future<void>.value();
  }

  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _channel.invokeMethod(
      'RemoteConfig#setDefaults',
      <String, dynamic> {
        'defaults': defaults
      }
    );
    return new Future<void>.value();
  }

  // getString
  String getString(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asString();
    } else {
      return defaultValueForString;
    }
  }

  // getInt
  int getInt(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asInt();
    } else {
      return defaultValueForInt;
    }
  }

  // getDouble
  double getDouble(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asDouble();
    } else {
      return defaultValueForDouble;
    }
  }

  // getBoolean
  bool getBool(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asBool();
    } else {
      return defaultValueForBool;
    }
  }

  RemoteConfigValue getValue(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key];
    } else {
      return new RemoteConfigValue._(null, ValueSource.valueStatic);
    }
  }

}
