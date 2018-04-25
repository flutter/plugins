part of firebase_performance;

class Trace {
  final FirebasePerformance _performance;
  final int _id;
  final String name;
  final TraceAndroid android;

  final HashMap<String, int> counters = new HashMap<String, int>();

  Trace._(this._performance, this._id, this.name)
      : android = defaultTargetPlatform == TargetPlatform.android
            ? new TraceAndroid._()
            : null;

  Future<void> start() async {
    await _performance._traceStart(this);
  }

  Future<void> stop() async {
    await _performance._traceStop(this);
  }

  void incrementCounter(String name, [int incrementBy = 1]) {
    counters.putIfAbsent(name, () => 0);
    counters[name] += incrementBy;
  }
}

class TraceAndroid {
  final HashMap<String, String> attributes = new HashMap<String, String>();

  TraceAndroid._();

  void putAttribute(String attribute, String value) {
    attributes.putIfAbsent(attribute, () => value);
    attributes[attribute] = value;
  }
  
  void removeAttribute(String attribute) {
    attributes.remove(attribute);
  }

  String getAttribute(String attribute) => attributes[attribute];
}