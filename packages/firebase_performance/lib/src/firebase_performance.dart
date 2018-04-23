part of firebase_performance;

class FirebasePerformance {
  final MethodChannel _channel;

  static final FirebasePerformance instance = new FirebasePerformance.private(
      const MethodChannel('plugins.flutter.io/firebase_performance'));

  /// We don't want people to extend this class, but implementing its interface,
  /// e.g. in tests, is OK.
  @visibleForTesting
  FirebasePerformance.private(MethodChannel platformChannel)
      : _channel = platformChannel;

  Future<bool> isPerformanceCollectionEnabled() async {
    final bool isEnabled = await _channel
        .invokeMethod('FirebasePerformance#isPerformanceCollectionEnabled');
    return isEnabled;
  }

  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    await _channel.invokeMethod(
        'FirebasePerformance#setPerformanceCollectionEnabled', enabled);
  }

  Future<void> _traceStart(Trace trace) async {
    await _channel.invokeMethod('Trace#start', trace._id);
  }

  Future<void> _traceStop(Trace trace) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': trace._id,
      'name': trace.name,
      'counters': trace.counters
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      data.putIfAbsent('attributes', () => trace.android.attributes);
    }

    await _channel.invokeMethod('Trace#stop', data);
  }

  Future<Trace> newTrace(String name) async {
    final int id = await _channel.invokeMethod('FirebasePerformance#newTrace', name);
    return new Trace._(id, name);
  }
}
