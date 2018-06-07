// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// The Dynamic Link iOS parameters.
class IosParameters {
  IosParameters({
    this.appStoreId,
    @required this.bundleId,
    this.customScheme,
    this.fallbackUrl,
    this.ipadBundleId,
    this.ipadFallbackUrl,
    this.minimumVersion,
  }) : assert(bundleId != null);

  /// The appStore ID of the iOS app in AppStore.
  final String appStoreId;

  /// The bundle ID of the iOS app to use to open the link.
  final String bundleId;

  /// The target app’s custom URL scheme.
  ///
  /// Defined to be something other than the app’s bundle ID.
  final String customScheme;

  /// The link to open when the app isn’t installed.
  ///
  /// Specify this to do something other than install the app from the App Store
  /// when the app isn’t installed, such as open the mobile web version of the
  /// content, or display a promotional page for the app.
  final Uri fallbackUrl;

  /// The bundle ID of the iOS app to use on iPads to open the link.
  ///
  /// This is only required if there are separate iPhone and iPad applications.
  final String ipadBundleId;

  /// The link to open on iPads when the app isn’t installed.
  ///
  /// Specify this to do something other than install the app from the App Store
  /// when the app isn’t installed, such as open the web version of the content,
  /// or display a promotional page for the app.
  final Uri ipadFallbackUrl;

  /// The the minimum version of your app that can open the link.
  ///
  /// It is app’s developer responsibility to open AppStore when received link
  /// declares higher [minimumVersion] than currently installed.
  final String minimumVersion;

  Map<String, dynamic> get _data => <String, dynamic>{
        'appStoreId': appStoreId,
        'bundleId': bundleId,
        'customScheme': customScheme,
        'fallbackUrl': fallbackUrl?.toString(),
        'ipadBundleId': ipadBundleId,
        'ipadFallbackUrl': ipadFallbackUrl?.toString(),
        'minimumVersion': minimumVersion,
      };
}
