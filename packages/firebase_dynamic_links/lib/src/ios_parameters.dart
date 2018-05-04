part of firebase_dynamic_links;

class IosParameters {
  IosParameters._({
    this.appStoreId,
    @required this.bundleId,
    this.customScheme,
    this.fallbackUri,
    this.ipadBundleId,
    this.ipadFallbackUri,
    this.minimumVersion,
  });

  final String appStoreId;
  final String bundleId;
  final String customScheme;
  final Uri fallbackUri;
  final String ipadBundleId;
  final Uri ipadFallbackUri;
  final String minimumVersion;

  Map<String, dynamic> get _data => <String, dynamic>{
        'appStoreId': appStoreId,
        'bundleId': bundleId,
        'customScheme': customScheme,
        'fallbackUri': fallbackUri.toString(),
        'ipadBundleId': ipadBundleId,
        'ipadFallbackUri': ipadFallbackUri.toString(),
        'minimumVersion': minimumVersion,
      };
}
