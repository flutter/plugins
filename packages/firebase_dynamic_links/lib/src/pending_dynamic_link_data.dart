// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// Provides data from received dynamic link.
class PendingDynamicLinkData {
  PendingDynamicLinkData._(this.link, this.android, this.ios);

  /// Provides Android specific data from received dynamic link.
  ///
  /// Can be null if [link] equals null or dynamic link was not received on an
  /// Android device.
  final PendingDynamicLinkDataAndroid android;

  /// Provides iOS specific data from received dynamic link.
  ///
  /// Can be null if [link] equals null or dynamic link was not received on an
  /// iOS device.
  final PendingDynamicLinkDataIOS ios;

  /// Deep link parameter of the dynamic link.
  final Uri link;
}

/// Provides android specific data from received dynamic link.
class PendingDynamicLinkDataAndroid {
  PendingDynamicLinkDataAndroid._(
    this.clickTimestamp,
    this.minimumVersion,
  );

  /// The time the user clicked on the dynamic link.
  ///
  /// Equals the number of milliseconds that have elapsed since January 1, 1970.
  final int clickTimestamp;

  /// The minimum version of your app that can open the link.
  ///
  /// The minimum Android app version requested to process the dynamic link that
  /// can be compared directly with versionCode.
  ///
  /// If the installed app is an older version, the user is taken to the Play
  /// Store to upgrade the app.
  final int minimumVersion;
}

/// Provides iOS specific data from received dynamic link.
class PendingDynamicLinkDataIOS {
  PendingDynamicLinkDataIOS._(this.minimumVersion);

  /// The minimum version of your app that can open the link.
  ///
  /// It is app developer's responsibility to open AppStore when received link
  /// declares higher [minimumVersion] than currently installed.
  final String minimumVersion;
}
