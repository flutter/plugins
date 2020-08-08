import 'dart:async';
import 'models/LinuxDeviceInfo.dart';
import 'package:device_info_platform_interface/device_info_platform_interface.dart';

class DeviceInfoLinux {
  /// This information does not change from call to call. Cache it.
  LinuxDeviceInfo _cachedLinuxDeviceInfo;

  /// Parsed information from /proc/meminfo, lspci and hostnamectl
  Future<LinuxDeviceInfo> get linuxInfo async =>
      _cachedLinuxDeviceInfo ??= LinuxDeviceInfo.fromMap(
        await DeviceInfoPlatform.instance.linuxInfo(),
      );
}
