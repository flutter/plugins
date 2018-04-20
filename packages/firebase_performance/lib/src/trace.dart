part of firebase_performance;

class Trace {
  final String name;
  final TraceAndroid android;

  @visibleForTesting
  final HashMap<String, int> counters = new HashMap<String, int>();

  Trace._(this.name)
      : android = defaultTargetPlatform == TargetPlatform.android
            ? new TraceAndroid._()
            : null;

  Future<void> start() {
    return null;
  }

  Future<void> stop() {
    return null;
  }

  void incrementCounter(String name, [int incrementBy = 1]) {
    counters.putIfAbsent(name, () => 0);
    counters[name] += incrementBy;
  }
}

class TraceAndroid {
  final HashMap<String, String> _attributes = new HashMap<String, String>();

  TraceAndroid._();

  Map<String, String> get attributes => _attributes;

  void putAttribute(String attribute, String value) {
    _attributes.putIfAbsent(attribute, () => value);
    _attributes[attribute] = value;
  }
  
  void removeAttribute(String attribute) {
    _attributes.remove(attribute);
  }

  String getAttribute(String attribute) => _attributes[attribute];
}