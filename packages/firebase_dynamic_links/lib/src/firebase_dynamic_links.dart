// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// Firebase Dynamic Links API.
///
/// You can get an instance by calling [FirebaseDynamicLinks.instance].
class FirebaseDynamicLinks {
  FirebaseDynamicLinks._();

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_dynamic_links');

  /// Singleton of [FirebaseDynamicLinks].
  static final FirebaseDynamicLinks instance = FirebaseDynamicLinks._();

  /// Attempts to retrieve a pending dynamic link.
  ///
  /// This method always returns a Future. That Future completes to null if
  /// there is no pending dynamic link or any call to this method after the
  /// the first attempt.
  Future<PendingDynamicLinkData> retrieveDynamicLink() async {
    final Map<dynamic, dynamic> linkData =
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await channel.invokeMethod('FirebaseDynamicLinks#retrieveDynamicLink');

    if (linkData == null) return null;

    PendingDynamicLinkDataAndroid androidData;
    if (linkData['android'] != null) {
      final Map<dynamic, dynamic> data = linkData['android'];
      androidData = PendingDynamicLinkDataAndroid._(
        data['clickTimestamp'],
        data['minimumVersion'],
      );
    }

    PendingDynamicLinkDataIOS iosData;
    if (linkData['ios'] != null) {
      final Map<dynamic, dynamic> data = linkData['ios'];
      iosData = PendingDynamicLinkDataIOS._(data['minimumVersion']);
    }

    return PendingDynamicLinkData._(
      Uri.parse(linkData['link']),
      androidData,
      iosData,
    );
  }
}

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
