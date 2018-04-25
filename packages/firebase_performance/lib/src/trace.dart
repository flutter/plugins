part of firebase_performance;

class Trace {
  final FirebasePerformance _performance;
  final int _id;
  final String name;

  final HashMap<String, int> counters = new HashMap<String, int>();
  final HashMap<String, String> attributes = new HashMap<String, String>();

  Trace._(this._performance, this._id, this.name);

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

  void putAttribute(String attribute, String value) {
    attributes.putIfAbsent(attribute, () => value);
    attributes[attribute] = value;
  }

  void removeAttribute(String attribute) {
    attributes.remove(attribute);
  }

  String getAttribute(String attribute) => attributes[attribute];
}