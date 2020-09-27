import 'package:package_info_platform_interface/package_info_platform_interface.dart';

import 'package:flutter/services.dart';

/// An implementation of [PackageInfoPlatform] that uses method channels.
class PackageInfoMethodChannel extends PackageInfoPlatform {
  const MethodChannel _kChannel =
      MethodChannel('plugins.flutter.io/package_info');

  @override
  Future<Map<String, String>> getAll() async {
	return await _kChannel.invokeMapMethod<String, String>('getAll');
  }
}