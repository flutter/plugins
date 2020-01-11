import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_cursor/custom_cursor.dart';

void main() {
  const MethodChannel channel = MethodChannel('custom_cursor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CustomCursor.platformVersion, '42');
  });
}
