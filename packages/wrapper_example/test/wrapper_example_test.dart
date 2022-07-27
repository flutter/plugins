import 'package:flutter_test/flutter_test.dart';
import 'package:wrapper_example/wrapper_example.dart';
import 'package:wrapper_example/wrapper_example_platform_interface.dart';
import 'package:wrapper_example/wrapper_example_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWrapperExamplePlatform
    with MockPlatformInterfaceMixin
    implements WrapperExamplePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WrapperExamplePlatform initialPlatform = WrapperExamplePlatform.instance;

  test('$MethodChannelWrapperExample is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWrapperExample>());
  });

  test('getPlatformVersion', () async {
    WrapperExample wrapperExamplePlugin = WrapperExample();
    MockWrapperExamplePlatform fakePlatform = MockWrapperExamplePlatform();
    WrapperExamplePlatform.instance = fakePlatform;

    expect(await wrapperExamplePlugin.getPlatformVersion(), '42');
  });
}
