// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// The Dynamic Link Social Meta Tag parameters.
class SocialMetaTagParameters {
  SocialMetaTagParameters({this.description, this.imageUrl, this.title});

  /// The description to use when the Dynamic Link is shared in a social post.
  final String description;

  /// The URL to an image related to this link.
  final Uri imageUrl;

  /// The title to use when the Dynamic Link is shared in a social post.
  final String title;

  Map<String, dynamic> get _data => <String, dynamic>{
        'description': description,
        'imageUrl': imageUrl?.toString(),
        'title': title,
      };
}
