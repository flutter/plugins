// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _kChannel = const MethodChannel('plugins.flutter.io/device_info');

/// This information does not change from call to call. Cache it.
AndroidOSBuild _cachedAndroidOSBuild;

/// Information derived from `android.os.Build`.
///
/// See: https://developer.android.com/reference/android/os/Build.html
Future<AndroidOSBuild> get androidOSBuild async => _cachedAndroidOSBuild ?? await _kChannel.invokeMethod('getAndroidOSBuild');

/// Information derived from `android.os.Build`.
///
/// See: https://developer.android.com/reference/android/os/Build.html
class AndroidOSBuild {
  AndroidOSBuild._({
    this.version,
    this.board,
    this.bootloader,
    this.brand,
    this.device,
    this.display,
    this.fingerprint,
    this.hardware,
    this.host,
    this.id,
    this.manufacturer,
    this.model,
    this.product,
    List<String> supported32BitAbis,
    List<String> supported64BitAbis,
    List<String> supportedAbis,
    this.tags,
    this.type,
  })
      : supported32BitAbis = new List<String>.unmodifiable(supported32BitAbis),
        supported64BitAbis = new List<String>.unmodifiable(supported64BitAbis),
        supportedAbis = new List<String>.unmodifiable(supportedAbis);

  /// Android operating system version values.
  final AndroidBuildVersion version;

  /// The name of the underlying board, like "goldfish".
  final String board;

  /// The system bootloader version number.
  final String bootloader;

  /// The consumer-visible brand with which the product/hardware will be associated, if any.
  final String brand;

  /// The name of the industrial design.
  final String device;

  /// A build ID string meant for displaying to the user.
  final String display;

  /// A string that uniquely identifies this build.
  final String fingerprint;

  /// The name of the hardware (from the kernel command line or /proc).
  final String hardware;

  /// Hostname.
  final String host;

  /// Either a changelist number, or a label like "M4-rc20".
  final String id;

  /// The manufacturer of the product/hardware.
  final String manufacturer;

  /// The end-user-visible name for the end product.
  final String model;

  /// The name of the overall product.
  final String product;

  /// An ordered list of 32 bit ABIs supported by this device.
  final List<String> supported32BitAbis;

  /// An ordered list of 64 bit ABIs supported by this device.
  final List<String> supported64BitAbis;

  /// An ordered list of ABIs supported by this device.
  final List<String> supportedAbis;

  /// Comma-separated tags describing the build, like "unsigned,debug".
  final String tags;

  /// The type of build, like "user" or "eng".
  final String type;
}

/// Version values of the current Android operating system build derived from
/// `android.os.Build.VERSION`.
///
/// See: https://developer.android.com/reference/android/os/Build.VERSION.html
class AndroidBuildVersion {
  AndroidBuildVersion({
    this.baseOS,
    this.codename,
    this.incremental,
    this.previewSdkInt,
    this.release,
    this.sdkInt,
    this.securityPatch,
  });

  /// The base OS build the product is based on.
  final String baseOS;

  /// The current development codename, or the string "REL" if this is a release build.
  final String codename;

  /// The internal value used by the underlying source control to represent this build.
  final String incremental;

  /// The developer preview revision of a prerelease SDK.
  final int previewSdkInt;

  /// The user-visible version string.
  final String release;

  /// The user-visible SDK version of the framework; its possible values are defined in [AndroidBuildVersionCodes].
  final int sdkInt;

  /// The user-visible security patch level.
  final String securityPatch;
}
