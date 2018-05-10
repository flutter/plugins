// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

class GoogleAnalyticsParameters {
  GoogleAnalyticsParameters({
    @required this.campaign,
    this.content,
    @required this.medium,
    @required this.source,
    this.term,
  });

  GoogleAnalyticsParameters.empty() :
        campaign = null,
        content = null,
        medium = null,
        source = null,
        term = null;

  final String campaign;
  final String content;
  final String medium;
  final String source;
  final String term;

  Map<String, dynamic> get _data => <String, dynamic>{
        'campaign': campaign,
        'content': content,
        'medium': medium,
        'source': source,
        'term': term,
      };
}
