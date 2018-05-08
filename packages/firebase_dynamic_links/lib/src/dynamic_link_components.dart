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
    this.longLink,
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
  Uri longLink;
  NavigationInfoParameters navigationInfoParameters;
  SocialMetaTagParameters socialMetaTagParameters;

  Future<Uri> get uri => _generateUri();

  Future<Uri> _generateUri() async {
    final Map<String, dynamic> data = <String, dynamic>{
      'androidParameters': androidParameters?._data,
      'domain': domain,
      'dynamicLinkComponentsOptions': dynamicLinkComponentsOptions?._data,
      'googleAnalyticsParameters': googleAnalyticsParameters?._data,
      'iosParameters': iosParameters?._data,
      'itunesConnectAnalyticsParameters':
          itunesConnectAnalyticsParameters?._data,
      'link': link?.toString(),
      'longLink': longLink?.toString(),
      'navigationInfoParameters': navigationInfoParameters?._data,
      'socialMetaTagParameters': socialMetaTagParameters?._data,
    };

    final String url = await FirebaseDynamicLinks.channel
        .invokeMethod("DynamicLinkComponents#uri", data);
    return Uri.parse(url);
  }
}
