part of firebase_remote_config;

/// LastFetchStatus defines the possible status values of the last fetch.
enum LastFetchStatus {
  success,
  failure,
  throttled,
  noFetchYet
}

class FetchThrottledException implements Exception {
  DateTime _throttleEnd;

  FetchThrottledException._({int endTimeInMills = 43200}) {
    _throttleEnd = new DateTime.fromMillisecondsSinceEpoch(endTimeInMills);
  }

  DateTime get throttleEnd => _throttleEnd;
  String get msg {
    final Duration duration = _throttleEnd.difference(new DateTime.now());
    return '''Fetching throttled try again in ${duration.inMilliseconds}
milliseconds''';
  }

  @override
  String toString() {
    final Duration duration = _throttleEnd.difference(new DateTime.now());
    return '''FetchThrottledException
Fetching throttled try again in ${duration.inMilliseconds} milliseconds''';
  }
}

/// The entry point for accessing Remote Config.
///
/// You can get an instance by calling [RemoteConfig.instance]. Note
/// [RemoteConfig.instance] is async.
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

  /// Set the configuration settings for this RemoteConfig instance.
  ///
  /// This can be used for enabling developer mode.
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

  /// Fetches parameter values for your app. Parameter values may be from
  /// Default Config (local cache) or Remote Config if enough time has elapsed
  /// since parameter values were last fetched from the server. The default
  /// expiration time is 12 hours.
  Future<void> fetch({int expiration: 43200}) async {
    try {
      final Map<String, dynamic> properties = await _channel.invokeMethod(
          'RemoteConfig#fetch',
          <String, dynamic>{
            'expiration': expiration
          }
      );
      _lastFetchTime = new DateTime.fromMillisecondsSinceEpoch(properties['LAST_FETCH_TIME']);
      _lastFetchStatus = LastFetchStatus.values[properties['LAST_FETCH_STATUS']];
    } on PlatformException catch(e) {
      if (e.code == RemoteConfig.fetchFailedThrottled) {
        final int fetchThrottleEnd = e.details['FETCH_THROTTLED_END'];
        throw new FetchThrottledException._(endTimeInMills: fetchThrottleEnd);
      } else {
        throw new Exception('Unable to fetch remote config');
      }
    }
    return new Future<void>.value();
  }

  /// Activates the fetched config. This makes fetched key-values take effect.
  ///
  /// The returned Future contains true if the fetched config is different
  /// from the currently activated config, it contains false otherwise.
  Future<bool> activateFetched() async {
    final Map<String, dynamic> rawParameters  = await _channel.invokeMethod(
      'RemoteConfig#activate'
    );
    final Map<String, RemoteConfigValue> fetchedParameters = <String, RemoteConfigValue>{};
    rawParameters.forEach((String key, dynamic value) {
      final ValueSource valueSource = ValueSource.values[value['source']];
      final RemoteConfigValue remoteConfigValue = new RemoteConfigValue._(value['value'], valueSource);
      fetchedParameters[key] = remoteConfigValue;
    });
    final MapEquality<String, RemoteConfigValue> mapEquality =
        const MapEquality<String, RemoteConfigValue>(
            keys: const Equality<String>(),
            values: const Equality<RemoteConfigValue>()
        );
    final bool newConfig = mapEquality.equals(_parameters, fetchedParameters);
    _parameters = fetchedParameters;
    return new Future<bool>.value(newConfig);
  }

  /// Sets the default config. Default config parameters should be set then when
  /// changes are needed the parameters should be updated in the Firebase
  /// console.
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _channel.invokeMethod(
      'RemoteConfig#setDefaults',
      <String, dynamic> {
        'defaults': defaults
      }
    );
    return new Future<void>.value();
  }

  /// Gets the value corresponding to the key as a String. If there is no
  /// parameter with corresponding key then the default String value is
  /// returned.
  String getString(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asString();
    } else {
      return defaultValueForString;
    }
  }

  /// Gets the value corresponding to the key as an int. If there is no
  /// parameter with corresponding key then the default int value is
  /// returned.
  int getInt(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asInt();
    } else {
      return defaultValueForInt;
    }
  }

  /// Gets the value corresponding to the key as a double. If there is no
  /// parameter with corresponding key then the default double value is
  /// returned.
  double getDouble(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asDouble();
    } else {
      return defaultValueForDouble;
    }
  }

  /// Gets the value corresponding to the key as a bool. If there is no
  /// parameter with corresponding key then the default bool value is
  /// returned.
  bool getBool(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asBool();
    } else {
      return defaultValueForBool;
    }
  }

  /// Gets the RemoteConfigValue corresponding to the key. If there is no
  /// parameter with corresponding key then a RemoteConfigValue with a null
  /// value and static source is returned.
  RemoteConfigValue getValue(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key];
    } else {
      return new RemoteConfigValue._(null, ValueSource.valueStatic);
    }
  }

}
