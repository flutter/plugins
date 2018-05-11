// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// Thrown to indicate an error occurred when creating a short Dynamic Link.
class ShortLinkException implements Exception {
  final String message;
  ShortLinkException(this.message);

  @override
  String toString() => '$runtimeType($message)';
}

/// The class used for Dynamic Link URL generation.
///
/// Supports creation of short and long Dynamic Link URLs. Short URLs will have
/// a domain and a randomized path. Long URLs will have a domain and a query
/// that contains all of the Dynamic Link parameters.
class DynamicLinkComponents {
  DynamicLinkComponents({
    this.androidParameters,
    @required this.domain,
    this.dynamicLinkComponentsOptions,
    this.googleAnalyticsParameters,
    this.iosParameters,
    this.itunesConnectAnalyticsParameters,
    @required this.link,
    this.navigationInfoParameters,
    this.socialMetaTagParameters,
  });

  /// Applies Android parameters to a generated Dynamic Link URL.
  AndroidParameters androidParameters;

  /// The Firebase project’s Dynamic Links domain.
  ///
  /// You can find this value in the Dynamic Links section of the Firebase
  /// console. https://console.firebase.google.com/
  String domain;

  /// Defines behavior for generating Dynamic Link URLs
  DynamicLinkComponentsOptions dynamicLinkComponentsOptions;

  /// Applies Analytics parameters to a generated Dynamic Link URL.
  GoogleAnalyticsParameters googleAnalyticsParameters;

  /// Applies iOS parameters to a generated Dynamic Link URL.
  IosParameters iosParameters;

  /// Applies iTunes Connect parameters to a generated Dynamic Link URL.
  ItunesConnectAnalyticsParameters itunesConnectAnalyticsParameters;

  /// The link the target app will open.
  ///
  /// You can specify any URL the app can handle, such as a link to the app’s
  /// content, or a URL that initiates some app-specific logic such as crediting
  /// the user with a coupon, or displaying a specific welcome screen.
  /// This link must be a well-formatted URL, be properly URL-encoded, and use
  /// the HTTP or HTTPS scheme.
  Uri link;

  /// Applies Navigation Info parameters to a generated Dynamic Link URL.
  NavigationInfoParameters navigationInfoParameters;

  /// Applies Social Meta Tag parameters to a generated Dynamic Link URL.
  SocialMetaTagParameters socialMetaTagParameters;

  /// Shortens a Dynamic Link URL.
  ///
  /// This method may be used for shortening a custom URL that was not generated
  /// using DynamicLinkComponents.
  ///
  /// May throw a [ShortLinkException].
  static Future<Uri> shortenUrl(Uri url,
      [DynamicLinkComponentsOptions options]) async {
    final Map<dynamic, dynamic> ret = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#shortenUrl", <String, dynamic>{
      'url': url.toString(),
      'dynamicLinkComponentsOptions': options?._data,
    });

    if (ret["code"] >= 0) {
      return Uri.parse(ret["url"]);
    } else {
      throw ShortLinkException(
          ret["errMsg"] ?? "Unable to create short Dynamic Link.");
    }
  }

  /// A generated long Dynamic Link URL.
  Future<Uri> get url => _generateUrl();

  /// A generated short Dynamic Link URL.
  ///
  /// May throw a [ShortLinkException].
  Future<Uri> get shortUrl => _generateShortUrl();

  Map<String, dynamic> get _data => <String, dynamic>{
        'androidParameters': androidParameters?._data,
        'domain': domain,
        'dynamicLinkComponentsOptions': dynamicLinkComponentsOptions?._data,
        'googleAnalyticsParameters': googleAnalyticsParameters?._data,
        'iosParameters': iosParameters?._data,
        'itunesConnectAnalyticsParameters':
            itunesConnectAnalyticsParameters?._data,
        'link': link.toString(),
        'navigationInfoParameters': navigationInfoParameters?._data,
        'socialMetaTagParameters': socialMetaTagParameters?._data,
      };

  Future<Uri> _generateUrl() async {
    final String url = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#url", _data);
    return Uri.parse(url);
  }

  Future<Uri> _generateShortUrl() async {
    final Map<dynamic, dynamic> ret = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#shortUrl", _data);

    if (ret["code"] >= 0) {
      return Uri.parse(ret["url"]);
    } else {
      throw ShortLinkException(
          ret["errMsg"] ?? "Unable to create short Dynamic Link.");
    }
  }
}
