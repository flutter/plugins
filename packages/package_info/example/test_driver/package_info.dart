import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:test/test.dart';

import '../test_live/package_info.dart' as live_test;

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));
  live_test.main();
}
