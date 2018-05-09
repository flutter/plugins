part of firebase_dynamic_links;

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

  AndroidParameters androidParameters;
  String domain;
  DynamicLinkComponentsOptions dynamicLinkComponentsOptions;
  GoogleAnalyticsParameters googleAnalyticsParameters;
  IosParameters iosParameters;
  ItunesConnectAnalyticsParameters itunesConnectAnalyticsParameters;
  Uri link;
  NavigationInfoParameters navigationInfoParameters;
  SocialMetaTagParameters socialMetaTagParameters;

  static Future<Uri> shortenUrl(Uri url,
      [DynamicLinkComponentsOptions options]) async {
    final String shortUrl = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#shortenUrl", <String, dynamic>{
      'url': url.toString(),
      'dynamicLinkComponentsOptions': options?._data,
    });
    return Uri.parse(shortUrl);
  }

  Future<Uri> get url => _generateUrl();
  Future<Uri> get shortUrl => _generateShortUrl();

  Map<String, dynamic> get _data => <String, dynamic>{
        'androidParameters': androidParameters?._data,
        'domain': domain,
        'dynamicLinkComponentsOptions': dynamicLinkComponentsOptions?._data,
        'googleAnalyticsParameters': googleAnalyticsParameters?._data,
        'iosParameters': iosParameters?._data,
        'itunesConnectAnalyticsParameters':
            itunesConnectAnalyticsParameters?._data,
        'link': link?.toString(),
        'navigationInfoParameters': navigationInfoParameters?._data,
        'socialMetaTagParameters': socialMetaTagParameters?._data,
      };

  Future<Uri> _generateUrl() async {
    final String url = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#url", _data);
    return Uri.parse(url);
  }

  Future<Uri> _generateShortUrl() async {
    final String shortUrl = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#shortUrl", _data);
    return Uri.parse(shortUrl);
  }
}
