part of firebase_remote_config;

/// The entry point for accessing Remote Config.
///
/// You can get an instance by calling [RemoteConfig.instance]. Note
/// [RemoteConfig.instance] is async.
class RemoteConfig extends ChangeNotifier {
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_remote_config');

  static const String defaultValueForString = '';
  static const int defaultValueForInt = 0;
  static const double defaultValueForDouble = 0.0;
  static const bool defaultValueForBool = false;

  Map<String, RemoteConfigValue> _parameters;

  DateTime _lastFetchTime;
  LastFetchStatus _lastFetchStatus;
  RemoteConfigSettings _remoteConfigSettings;

  DateTime get lastFetchTime => _lastFetchTime;
  LastFetchStatus get lastFetchStatus => _lastFetchStatus;
  RemoteConfigSettings get remoteConfigSettings => _remoteConfigSettings;

  static Completer<RemoteConfig> _instanceCompleter = Completer<RemoteConfig>();

  /// Gets the instance of RemoteConfig for the default Firebase app.
  static Future<RemoteConfig> get instance async {
    if (!_instanceCompleter.isCompleted) {
      _getRemoteConfigInstance();
    }
    return _instanceCompleter.future;
  }

  static void _getRemoteConfigInstance() async {
    final Map<dynamic, dynamic> properties =
        await channel.invokeMethod('RemoteConfig#instance');

    final RemoteConfig instance = RemoteConfig();

    instance._lastFetchTime =
        DateTime.fromMillisecondsSinceEpoch(properties['lastFetchTime']);
    instance._lastFetchStatus =
        _parseLastFetchStatus(properties['lastFetchStatus']);
    final RemoteConfigSettings remoteConfigSettings =
        RemoteConfigSettings(debugMode: properties['inDebugMode']);
    instance._remoteConfigSettings = remoteConfigSettings;
    instance._parameters =
        _parseRemoteConfigParameters(parameters: properties['parameters']);
    _instanceCompleter.complete(instance);
  }

  static Map<String, RemoteConfigValue> _parseRemoteConfigParameters(
      {Map<dynamic, dynamic> parameters}) {
    final Map<String, RemoteConfigValue> parsedParameters =
        <String, RemoteConfigValue>{};
    parameters.forEach((dynamic key, dynamic value) {
      final ValueSource valueSource = _parseValueSource(value['source']);
      final RemoteConfigValue remoteConfigValue =
          RemoteConfigValue._(value['value'].cast<int>(), valueSource);
      parsedParameters[key] = remoteConfigValue;
    });
    return parsedParameters;
  }

  static ValueSource _parseValueSource(String sourceStr) {
    switch (sourceStr) {
      case 'valueStatic':
        return ValueSource.valueStatic;
      case 'valueDefault':
        return ValueSource.valueDefault;
      case 'valueRemote':
        return ValueSource.valueRemote;
      default:
        return ValueSource.valueStatic;
    }
  }

  static LastFetchStatus _parseLastFetchStatus(String statusStr) {
    switch (statusStr) {
      case 'success':
        return LastFetchStatus.success;
      case 'failure':
        return LastFetchStatus.failure;
      case 'throttled':
        return LastFetchStatus.throttled;
      case 'noFetchYet':
        return LastFetchStatus.noFetchYet;
      default:
        return LastFetchStatus.failure;
    }
  }

  /// Set the configuration settings for this [RemoteConfig] instance.
  ///
  /// This can be used for enabling developer mode.
  Future<void> setConfigSettings(
      RemoteConfigSettings remoteConfigSettings) async {
    await channel
        .invokeMethod('RemoteConfig#setConfigSettings', <String, dynamic>{
      'debugMode': remoteConfigSettings.debugMode,
    });
    _remoteConfigSettings = remoteConfigSettings;
  }

  /// Fetches parameter values for your app.
  ///
  /// Parameter values may be from Default Config (local cache) or Remote
  /// Config if enough time has elapsed since parameter values were last
  /// fetched from the server. The default expiration time is 12 hours.
  /// Expiration must be defined in seconds.
  Future<void> fetch({Duration expiration = const Duration(hours: 12)}) async {
    try {
      final Map<dynamic, dynamic> properties = await channel.invokeMethod(
          'RemoteConfig#fetch',
          <dynamic, dynamic>{'expiration': expiration.inSeconds});
      _lastFetchTime =
          DateTime.fromMillisecondsSinceEpoch(properties['lastFetchTime']);
      _lastFetchStatus = _parseLastFetchStatus(properties['lastFetchStatus']);
    } on PlatformException catch (e) {
      _lastFetchTime =
          DateTime.fromMillisecondsSinceEpoch(e.details['lastFetchTime']);
      _lastFetchStatus = _parseLastFetchStatus(e.details['lastFetchStatus']);
      if (e.code == 'fetchFailedThrottled') {
        final int fetchThrottleEnd = e.details['fetchThrottledEnd'];
        throw FetchThrottledException._(endTimeInMills: fetchThrottleEnd);
      } else {
        throw Exception('Unable to fetch remote config');
      }
    }
  }

  /// Activates the fetched config, makes fetched key-values take effect.
  ///
  /// The returned Future completes true if the fetched config is different
  /// from the currently activated config, it contains false otherwise.
  Future<bool> activateFetched() async {
    final Map<dynamic, dynamic> properties =
        await channel.invokeMethod('RemoteConfig#activate');
    final Map<dynamic, dynamic> rawParameters = properties['parameters'];
    final bool newConfig = properties['newConfig'];
    final Map<String, RemoteConfigValue> fetchedParameters =
        _parseRemoteConfigParameters(parameters: rawParameters);
    _parameters = fetchedParameters;
    notifyListeners();
    return newConfig;
  }

  /// Sets the default config.
  ///
  /// Default config parameters should be set then when changes are needed the
  /// parameters should be updated in the Firebase console.
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    // Make defaults available even if fetch fails.
    defaults.forEach((String key, dynamic value) {
      if (!_parameters.containsKey(key)) {
        final ValueSource valueSource = ValueSource.valueDefault;
        final RemoteConfigValue remoteConfigValue = RemoteConfigValue._(
          const Utf8Codec().encode(value.toString()),
          valueSource,
        );
        _parameters[key] = remoteConfigValue;
      }
    });
    await channel.invokeMethod(
        'RemoteConfig#setDefaults', <String, dynamic>{'defaults': defaults});
  }

  /// Gets the value corresponding to the [key] as a String.
  ///
  /// If there is no parameter with corresponding [key] then the default
  /// String value is returned.
  String getString(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asString();
    } else {
      return defaultValueForString;
    }
  }

  /// Gets the value corresponding to the [key] as an int.
  ///
  /// If there is no parameter with corresponding [key] then the default
  /// int value is returned.
  int getInt(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asInt();
    } else {
      return defaultValueForInt;
    }
  }

  /// Gets the value corresponding to the [key] as a double.
  ///
  /// If there is no parameter with corresponding [key] then the default double
  /// value is returned.
  double getDouble(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asDouble();
    } else {
      return defaultValueForDouble;
    }
  }

  /// Gets the value corresponding to the [key] as a bool.
  ///
  /// If there is no parameter with corresponding [key] then the default bool
  /// value is returned.
  bool getBool(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asBool();
    } else {
      return defaultValueForBool;
    }
  }

  /// Gets the [RemoteConfigValue] corresponding to the [key].
  ///
  /// If there is no parameter with corresponding key then a [RemoteConfigValue]
  /// with a null value and static source is returned.
  RemoteConfigValue getValue(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key];
    } else {
      return RemoteConfigValue._(null, ValueSource.valueStatic);
    }
  }
}
