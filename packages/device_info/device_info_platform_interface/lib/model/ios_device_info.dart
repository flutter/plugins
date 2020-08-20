// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Information derived from `UIDevice`.
///
/// See: https://developer.apple.com/documentation/uikit/uidevice
class IosDeviceInfo {
  /// IOS device info class.
  IosDeviceInfo({
    this.name,
    this.systemName,
    this.systemVersion,
    this.model,
    this.localizedModel,
    this.identifierForVendor,
    this.isPhysicalDevice,
    this.utsname,
  });

  /// Device name.
  final String name;

  /// The name of the current operating system.
  final String systemName;

  /// The current operating system version.
  final String systemVersion;

  /// Device model.
  final String model;

  /// Localized name of the device model.
  final String localizedModel;

  /// Unique UUID value identifying the current device.
  final String identifierForVendor;

  /// `false` if the application is running in a simulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// Operating system information derived from `sys/utsname.h`.
  final IosUtsname utsname;

  /// Deserializes from the map message received from [_kChannel].
  static IosDeviceInfo fromMap(Map<String, dynamic> map) {
    return IosDeviceInfo(
      name: map['name'],
      systemName: map['systemName'],
      systemVersion: map['systemVersion'],
      model: map['model'],
      localizedModel: map['localizedModel'],
      identifierForVendor: map['identifierForVendor'],
      isPhysicalDevice: map['isPhysicalDevice'] == 'true',
      utsname:
          IosUtsname._fromMap(map['utsname']?.cast<String, dynamic>() ?? {}),
    );
  }
}

/// Information derived from `utsname`.
/// See http://pubs.opengroup.org/onlinepubs/7908799/xsh/sysutsname.h.html for details.
class IosUtsname {
  IosUtsname._({
    this.sysname,
    this.nodename,
    this.release,
    this.version,
    this.machine,
  });

  /// Operating system name.
  final String sysname;

  /// Network node name.
  final String nodename;

  /// Release level.
  final String release;

  /// Version level.
  final String version;

  /// Hardware type (e.g. 'iPhone7,1' for iPhone 6 Plus).
  final String machine;

  /// Deserializes from the map message received from [_kChannel].
  static IosUtsname _fromMap(Map<String, dynamic> map) {
    return IosUtsname._(
      sysname: map['sysname'],
      nodename: map['nodename'],
      release: map['release'],
      version: map['version'],
      machine: map['machine'],
    );
  }
}
