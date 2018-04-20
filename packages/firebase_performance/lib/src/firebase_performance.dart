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

  Trace newTrace(String name) {
    return new Trace._(name);
  }
}
