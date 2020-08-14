import 'package:device_info_platform_interface/model/androidDeviceIno.dart';
import 'package:device_info_platform_interface/model/iosDeviceInfo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_info_platform_interface/method_channel_device_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("$MethodChannelDeviceInfo", () {
    MethodChannelDeviceInfo methodChannelDeviceInfo;

    setUp(() async {
      methodChannelDeviceInfo = MethodChannelDeviceInfo();

      methodChannelDeviceInfo.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAndroidDeviceInfo':
            return ({
              "brand": "Google",
            });
          case 'getIosDeviceInfo':
            return ({
              "name": "iPhone 10",
            });
          default:
            return null;
        }
      });
    });

    test("androidInfo", () async {
      final AndroidDeviceInfo result =
          await methodChannelDeviceInfo.androidInfo();
      expect(result.brand, "Google");
    });

    test("iosInfo", () async {
      final IosDeviceInfo result = await methodChannelDeviceInfo.iosInfo();
      expect(result.name, "iPhone 10");
    });
  });
}
