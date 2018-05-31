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
      const MethodChannel('plugins.flutter.io/firebase_dynamic_links');

  /// Singleton of [FirebaseDynamicLinks].
  static final FirebaseDynamicLinks instance = new FirebaseDynamicLinks._();

  Future<PendingDynamicLinkData> retrieveDynamicLink() async {
    final String reply =
        await channel.invokeMethod("FirebaseDynamicLinks#retrieveDynamicLink");

    if (reply == null) return null;

    return PendingDynamicLinkData._(Uri.parse(reply));
  }
}
