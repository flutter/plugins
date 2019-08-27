import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instrumentation_adapter/instrumentation_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('instrumentation_adapter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await InstrumentationAdapter.platformVersion, '42');
  });
}
