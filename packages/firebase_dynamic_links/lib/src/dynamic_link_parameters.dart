// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// The class used for Dynamic Link URL generation.
///
/// Supports creation of short and long Dynamic Link URLs. Short URLs will have
/// a domain and a randomized path. Long URLs will have a domain and a query
/// that contains all of the Dynamic Link parameters.
class DynamicLinkParameters {
  DynamicLinkParameters({
    this.androidParameters,
    @required this.domain,
    this.dynamicLinkParametersOptions,
    this.googleAnalyticsParameters,
    this.iosParameters,
    this.itunesConnectAnalyticsParameters,
    @required this.link,
    this.navigationInfoParameters,
    this.socialMetaTagParameters,
  })  : assert(domain != null),
        assert(link != null);

  /// Android parameters for a generated Dynamic Link URL.
  final AndroidParameters androidParameters;

  /// The Firebase project’s Dynamic Links domain.
  ///
  /// You can find this value in the Dynamic Links section of the Firebase
  /// console. https://console.firebase.google.com/
  final String domain;

  /// Defines behavior for generating Dynamic Link URLs.
  final DynamicLinkParametersOptions dynamicLinkParametersOptions;

  /// Analytics parameters for a generated Dynamic Link URL.
  final GoogleAnalyticsParameters googleAnalyticsParameters;

  /// iOS parameters for a generated Dynamic Link URL.
  final IosParameters iosParameters;

  /// iTunes Connect parameters for a generated Dynamic Link URL.
  final ItunesConnectAnalyticsParameters itunesConnectAnalyticsParameters;

  /// The link the target app will open.
  ///
  /// You can specify any URL the app can handle, such as a link to the app’s
  /// content, or a URL that initiates some app-specific logic such as crediting
  /// the user with a coupon, or displaying a specific welcome screen.
  /// This link must be a well-formatted URL, be properly URL-encoded, and use
  /// the HTTP or HTTPS scheme.
  final Uri link;

  /// Navigation Info parameters for a generated Dynamic Link URL.
  final NavigationInfoParameters navigationInfoParameters;

  /// Social Meta Tag parameters for a generated Dynamic Link URL.
  final SocialMetaTagParameters socialMetaTagParameters;

  /// Shortens a Dynamic Link URL.
  ///
  /// This method may be used for shortening a custom URL that was not generated
  /// using [DynamicLinkParameters].
  static Future<ShortDynamicLink> shortenUrl(Uri url,
      [DynamicLinkParametersOptions options]) async {
    final Map<dynamic, dynamic> reply = await FirebaseDynamicLinks.channel
        .invokeMethod('DynamicLinkParameters#shortenUrl', <String, dynamic>{
      'url': url.toString(),
      'dynamicLinkParametersOptions': options?._data,
    });
    return _parseShortLink(reply);
  }

  Map<String, dynamic> get _data => <String, dynamic>{
        'androidParameters': androidParameters?._data,
        'domain': domain,
        'dynamicLinkParametersOptions': dynamicLinkParametersOptions?._data,
        'googleAnalyticsParameters': googleAnalyticsParameters?._data,
        'iosParameters': iosParameters?._data,
        'itunesConnectAnalyticsParameters':
            itunesConnectAnalyticsParameters?._data,
        'link': link.toString(),
        'navigationInfoParameters': navigationInfoParameters?._data,
        'socialMetaTagParameters': socialMetaTagParameters?._data,
      };

  /// Generate a long Dynamic Link URL.
  Future<Uri> buildUrl() async {
    final String url = await FirebaseDynamicLinks.channel
        .invokeMethod('DynamicLinkParameters#buildUrl', _data);
    return Uri.parse(url);
  }

  /// Generate a short Dynamic Link.
  Future<ShortDynamicLink> buildShortLink() async {
    final Map<dynamic, dynamic> reply = await FirebaseDynamicLinks.channel
        .invokeMethod('DynamicLinkParameters#buildShortLink', _data);
    return _parseShortLink(reply);
  }

  static ShortDynamicLink _parseShortLink(Map<dynamic, dynamic> reply) {
    final List<dynamic> warnings = reply['warnings'];
    return ShortDynamicLink._(Uri.parse(reply['url']), warnings?.cast());
  }
}
