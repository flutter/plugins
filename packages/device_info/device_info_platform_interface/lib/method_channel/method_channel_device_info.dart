import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'package:device_info_platform_interface/device_info_platform_interface.dart';

/// An implementation of [DeviceInfoPlatform] that uses method channels.
class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel channel = MethodChannel('plugins.flutter.io/device_info');

  // Method channel for Android devices
  Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      (await channel.invokeMethod('getAndroidDeviceInfo'))
          .cast<String, dynamic>(),
    );
  }

  // Method channel for iOS devices
  Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      (await channel.invokeMethod('getIosDeviceInfo')).cast<String, dynamic>(),
    );
  }
}
