// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

class ItunesConnectAnalyticsParameters {
  ItunesConnectAnalyticsParameters(
      {this.affiliateToken, this.campaignToken, this.providerToken});

  final String affiliateToken;
  final String campaignToken;
  final String providerToken;

  Map<String, dynamic> get _data => <String, dynamic>{
        'affiliateToken': affiliateToken,
        'campaignToken': campaignToken,
        'providerToken': providerToken,
      };
}
