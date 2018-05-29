// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// The Dynamic Link analytics parameters.
class GoogleAnalyticsParameters {
  GoogleAnalyticsParameters({
    @required this.campaign,
    this.content,
    @required this.medium,
    @required this.source,
    this.term,
  })  : assert(campaign != null),
        assert(medium != null),
        assert(source != null);

  GoogleAnalyticsParameters.empty()
      : campaign = null,
        content = null,
        medium = null,
        source = null,
        term = null;

  /// The utm_campaign analytics parameter.
  final String campaign;

  /// The utm_content analytics parameter.
  final String content;

  /// The utm_medium analytics parameter.
  final String medium;

  /// The utm_source analytics parameter.
  final String source;

  /// The utm_term analytics parameter.
  final String term;

  Map<String, dynamic> get _data => <String, dynamic>{
        'campaign': campaign,
        'content': content,
        'medium': medium,
        'source': source,
        'term': term,
      };
}
