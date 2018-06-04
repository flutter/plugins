// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

class PendingDynamicLinkData {
  PendingDynamicLinkData._(this.link, this.android, this.ios);

  final PendingDynamicLinkDataAndroid android;
  final PendingDynamicLinkDataIOS ios;

  final Uri link;
}

class PendingDynamicLinkDataAndroid {
  PendingDynamicLinkDataAndroid._(
    this.clickTimestamp,
    this.minimumVersion,
  );

  final int clickTimestamp;
  final int minimumVersion;
}

class PendingDynamicLinkDataIOS {
  PendingDynamicLinkDataIOS._(this.minimumVersion);

  final String minimumVersion;
}
