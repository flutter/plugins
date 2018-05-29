// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// Response from creating a short dynamic link with [DynamicLinkComponents].
class ShortDynamicLink {
  ShortDynamicLink._(this.shortUrl, this.warnings);

  /// Short url value.
  final Uri shortUrl;

  /// Information about potential warnings on link creation.
  final List<String> warnings;
}
