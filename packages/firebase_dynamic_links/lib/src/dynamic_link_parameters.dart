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
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
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
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('DynamicLinkParameters#buildUrl', _data);
    return Uri.parse(url);
  }

  /// Generate a short Dynamic Link.
  Future<ShortDynamicLink> buildShortLink() async {
    final Map<dynamic, dynamic> reply = await FirebaseDynamicLinks.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('DynamicLinkParameters#buildShortLink', _data);
    return _parseShortLink(reply);
  }

  static ShortDynamicLink _parseShortLink(Map<dynamic, dynamic> reply) {
    final List<dynamic> warnings = reply['warnings'];
    return ShortDynamicLink._(Uri.parse(reply['url']), warnings?.cast());
  }
}

/// Response from creating a short dynamic link with [DynamicLinkParameters].
class ShortDynamicLink {
  ShortDynamicLink._(this.shortUrl, this.warnings);

  /// Short url value.
  final Uri shortUrl;

  /// Information about potential warnings on link creation.
  final List<String> warnings;
}

/// The Dynamic Link Android parameters.
class AndroidParameters {
  AndroidParameters(
      {this.fallbackUrl, this.minimumVersion, @required this.packageName})
      : assert(packageName != null);

  /// The link to open when the app isn’t installed.
  ///
  /// Specify this to do something other than install the app from the Play
  /// Store when the app isn’t installed, such as open the mobile web version of
  /// the content, or display a promotional page for the app.
  final Uri fallbackUrl;

  /// The version of the minimum version of your app that can open the link.
  ///
  /// If the installed app is an older version, the user is taken to the Play
  /// Store to upgrade the app.
  final int minimumVersion;

  /// The Android app’s package name.
  final String packageName;

  Map<String, dynamic> get _data => <String, dynamic>{
        'fallbackUrl': fallbackUrl?.toString(),
        'minimumVersion': minimumVersion,
        'packageName': packageName,
      };
}

/// For specifying length for short Dynamic Links.
enum ShortDynamicLinkPathLength { unguessable, short }

/// Options class for defining how Dynamic Link URLs are generated.
class DynamicLinkParametersOptions {
  DynamicLinkParametersOptions({this.shortDynamicLinkPathLength});

  /// Specifies the length of the path component of a short Dynamic Link.
  final ShortDynamicLinkPathLength shortDynamicLinkPathLength;

  Map<String, dynamic> get _data => <String, dynamic>{
        'shortDynamicLinkPathLength': shortDynamicLinkPathLength?.index,
      };
}

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

/// The Dynamic Link iOS parameters.
class IosParameters {
  IosParameters({
    this.appStoreId,
    @required this.bundleId,
    this.customScheme,
    this.fallbackUrl,
    this.ipadBundleId,
    this.ipadFallbackUrl,
    this.minimumVersion,
  }) : assert(bundleId != null);

  /// The appStore ID of the iOS app in AppStore.
  final String appStoreId;

  /// The bundle ID of the iOS app to use to open the link.
  final String bundleId;

  /// The target app’s custom URL scheme.
  ///
  /// Defined to be something other than the app’s bundle ID.
  final String customScheme;

  /// The link to open when the app isn’t installed.
  ///
  /// Specify this to do something other than install the app from the App Store
  /// when the app isn’t installed, such as open the mobile web version of the
  /// content, or display a promotional page for the app.
  final Uri fallbackUrl;

  /// The bundle ID of the iOS app to use on iPads to open the link.
  ///
  /// This is only required if there are separate iPhone and iPad applications.
  final String ipadBundleId;

  /// The link to open on iPads when the app isn’t installed.
  ///
  /// Specify this to do something other than install the app from the App Store
  /// when the app isn’t installed, such as open the web version of the content,
  /// or display a promotional page for the app.
  final Uri ipadFallbackUrl;

  /// The the minimum version of your app that can open the link.
  ///
  /// It is app’s developer responsibility to open AppStore when received link
  /// declares higher [minimumVersion] than currently installed.
  final String minimumVersion;

  Map<String, dynamic> get _data => <String, dynamic>{
        'appStoreId': appStoreId,
        'bundleId': bundleId,
        'customScheme': customScheme,
        'fallbackUrl': fallbackUrl?.toString(),
        'ipadBundleId': ipadBundleId,
        'ipadFallbackUrl': ipadFallbackUrl?.toString(),
        'minimumVersion': minimumVersion,
      };
}

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

/// Options class for defining navigation behavior of the Dynamic Link.
class NavigationInfoParameters {
  NavigationInfoParameters({this.forcedRedirectEnabled});

  /// Whether forced non-interactive redirect it to be used.
  ///
  /// Forced non-interactive redirect occurs when link is tapped on mobile
  /// device.
  ///
  /// Default behavior is to disable force redirect and show interstitial page
  /// where user tap will initiate navigation to the App (or AppStore if not
  /// installed). Disabled force redirect normally improves reliability of the
  /// click.
  final bool forcedRedirectEnabled;

  Map<String, dynamic> get _data => <String, dynamic>{
        'forcedRedirectEnabled': forcedRedirectEnabled,
      };
}

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
