// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// The Dynamic Link iTunes Connect parameters.
class ItunesConnectAnalyticsParameters {
  ItunesConnectAnalyticsParameters(
      {this.affiliateToken, this.campaignToken, this.providerToken});

  /// The iTunes Connect affiliate token.
  final String affiliateToken;

  /// The iTunes Connect campaign token.
  final String campaignToken;

  /// The iTunes Connect provider token.
  final String providerToken;

  Map<String, dynamic> get _data => <String, dynamic>{
        'affiliateToken': affiliateToken,
        'campaignToken': campaignToken,
        'providerToken': providerToken,
      };
}
