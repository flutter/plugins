part of firebase_dynamic_links;

class IosParameters {
  IosParameters({
    this.appStoreId,
    @required this.bundleId,
    this.customScheme,
    this.fallbackUrl,
    this.ipadBundleId,
    this.ipadFallbackUrl,
    this.minimumVersion,
  });

  final String appStoreId;
  final String bundleId;
  final String customScheme;
  final Uri fallbackUrl;
  final String ipadBundleId;
  final Uri ipadFallbackUrl;
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
