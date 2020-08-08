import 'dart:async';

import 'package:flutter/services.dart';

import 'device_info_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/device_info');

/// An implementation of [DeviceInfoPlatform] that uses method channels.
class MethodChannelDeviceInfo extends DeviceInfoPlatform {

  // Method channel for Linux devices.
  Future<Map<String, dynamic>> linuxInfo() async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('getLinuxInfo'));
  }

  // Method channel for Android devices
  Future<Map<String, dynamic>> androidInfo() async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('getAndroidDeviceInfo'));
  }

  // Method channel for iOS devices
  Future<Map<String, dynamic>> iosInfo() async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('getIosDeviceInfo'));
  }
}
