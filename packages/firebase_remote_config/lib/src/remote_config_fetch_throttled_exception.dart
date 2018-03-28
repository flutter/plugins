part of firebase_remote_config;

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
