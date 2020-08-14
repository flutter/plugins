import 'dart:async';

import 'package:flutter/services.dart';
import 'package:device_info_platform_interface/model/androidDeviceIno.dart';
import 'package:device_info_platform_interface/model/iosDeviceInfo.dart';

import 'device_info_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/device_info');

/// An implementation of [DeviceInfoPlatform] that uses method channels.
class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  // Method channel for Android devices
  Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      Map<String, dynamic>.from(
        await _channel.invokeMethod('getAndroidDeviceInfo'),
      ),
    );
  }

  // Method channel for iOS devices
  Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      Map<String, dynamic>.from(
        await _channel.invokeMethod('getIosDeviceInfo'),
      ),
    );
  }
}
