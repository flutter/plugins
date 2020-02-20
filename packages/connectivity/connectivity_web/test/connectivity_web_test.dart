import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_web/connectivity_web.dart';

void main() {
  const MethodChannel channel = MethodChannel('connectivity_web');

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
    expect(await ConnectivityWeb.platformVersion, '42');
  });
}
