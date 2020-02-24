import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  setUp(() {
    print('Hello, testing!');
  });

  tearDown(() {
    print('Bye, testing!');
  });

  test('getPlatformVersion', () async {

    print('Testing some!');
  
  });
}
