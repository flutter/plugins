part of firebase_performance;

class FirebasePerformance {
  static const String traceCounterPrefix = "c_";
  static const String traceAttrPrefix = "a_";

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
    final Map<String, dynamic> data = <String, dynamic>{
      'id': trace.id,
      'name': trace.name,jjjjnjj
    };

    final Map<String, int> counters = new Map.fromIterable(trace.counters.keys,
        key: (item) => traceCounterPrefix + item,
        value: (item) => trace.counters[item]);

    data.addAll(counters);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, String> attrs = new Map.fromIterable(
          trace.android.attributes.keys,
          key: (item) => traceAttrPrefix + item,
          value: (item) => trace.android.attributes[item]);

      data.addAll(attrs);
    }

    await _channel.invokeMethod('Trace#start', data);
  }

  Future<void> _traceStop(Trace trace) async {
    await _channel.invokeMethod('Trace#stop', trace.id);
  }

  Future<Trace> newTrace(String name) async {
    final int id = await _channel.invokeMethod('FirebasePerformance#newTrace');
    return new Trace._(id, name);
  }
}
