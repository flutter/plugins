import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:device_info/device_info.dart';

void main() {
  MockChannel ch;
  DeviceInfoPlugin deviceInfo;

  setUp(() {
    ch = MockChannel();
    deviceInfo = DeviceInfoPlugin.private(ch);
  });

  test('IosDeviceInfo', () async {
    const Map<String, dynamic> mockData = <String, dynamic>{
      "name": "ios name",
      "systemName": "ios systemName",
      "systemVersion": "ios systemVersion",
      "model": "ios model",
      "localizedModel": "ios localizedModel",
      "identifierForVendor": "ios identifierForVendor",
      "isPhysicalDevice": "true",
      "utsname": <String, String>{
        "sysname": "ios.utsname.sysname",
        "nodename": "ios.utsname.nodename",
        "release": "ios.utsname.release",
        "version": "ios.utsname.version",
        "machine": "ios.utsname.machine",
      },
    };
    when(ch.invokeMethod('getIosDeviceInfo')).thenAnswer(
        (Invocation invoke) => Future<Map<dynamic, dynamic>>.value(mockData));
    final IosDeviceInfo r = await deviceInfo.iosInfo;

    expect(r.name, "ios name");
    expect(r.systemName, "ios systemName");
    expect(r.systemVersion, "ios systemVersion");
    expect(r.model, "ios model");
    expect(r.localizedModel, "ios localizedModel");
    expect(r.identifierForVendor, "ios identifierForVendor");
    expect(r.isPhysicalDevice, true);

    expect(r.utsname.sysname, "ios.utsname.sysname");
    expect(r.utsname.nodename, "ios.utsname.nodename");
    expect(r.utsname.release, "ios.utsname.release");
    expect(r.utsname.version, "ios.utsname.version");
    expect(r.utsname.machine, "ios.utsname.machine");
  });
}

class MockChannel extends Mock implements MethodChannel {}
