part of firebase_crashlytics;

class TestError extends Error {

  TestError(this.msg);

  String msg;
}

class Crashlytics {

  static final Crashlytics instance = Crashlytics();

  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_crashlytics');

  Future<void> error() async {
    throw TestError('i am working');
  }



  Future<void> log(String level, String tag, String message) {

  }

  Future<void> onError(FlutterErrorDetails details) {
    print('calling native crash');
    List<String> lines = details.stack.toString().trimRight().split('\n');
    channel.invokeMethod('Crashlytics#onError', <String, dynamic>{
      'exception': details.exceptionAsString(),
      'stackTrace': lines
    }).then((dynamic d) {
      print('crash complete');
    });
  }
}

