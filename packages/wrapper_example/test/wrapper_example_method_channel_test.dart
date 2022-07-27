import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrapper_example/wrapper_example_method_channel.dart';

void main() {
  MethodChannelWrapperExample platform = MethodChannelWrapperExample();
  const MethodChannel channel = MethodChannel('wrapper_example');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
