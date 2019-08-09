import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:test/test.dart';

import '../test/package_info.dart' as test;

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));
  test.main();
}
