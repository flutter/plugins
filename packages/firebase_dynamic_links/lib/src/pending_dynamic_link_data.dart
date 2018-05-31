// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

class PendingDynamicLinkData {
  PendingDynamicLinkData._(this.link)
      : android = defaultTargetPlatform == TargetPlatform.android
            ? PendingDynamicLinkDataAndroid._()
            : null,
        ios = defaultTargetPlatform == TargetPlatform.iOS
            ? PendingDynamicLinkDataIOS._()
            : null;

  final PendingDynamicLinkDataAndroid android;
  final PendingDynamicLinkDataIOS ios;

  final Uri link;
}

class PendingDynamicLinkDataAndroid {
  PendingDynamicLinkDataAndroid._();
}

class PendingDynamicLinkDataIOS {
  PendingDynamicLinkDataIOS._();
}
