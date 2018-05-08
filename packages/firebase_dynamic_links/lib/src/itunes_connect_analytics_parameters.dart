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
