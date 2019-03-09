part of firebase_remote_config;

/// Exception thrown when the fetch() operation cannot be completed successfully, due to throttling.
class FetchThrottledException implements Exception {
  FetchThrottledException._({int endTimeInMills}) {
    _throttleEnd = DateTime.fromMillisecondsSinceEpoch(endTimeInMills);
  }

  DateTime _throttleEnd;

  DateTime get throttleEnd => _throttleEnd;

  @override
  String toString() {
    final Duration duration = _throttleEnd.difference(DateTime.now());
    return '''FetchThrottledException
Fetching throttled, try again in ${duration.inMilliseconds} milliseconds''';
  }
}
