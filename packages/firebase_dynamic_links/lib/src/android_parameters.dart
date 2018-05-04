part of firebase_dynamic_links;

class AndroidParameters {
  AndroidParameters(
      {this.fallbackUri, this.minimumVersion, @required this.packageName});

  final Uri fallbackUri;
  final int minimumVersion;
  final String packageName;

  Map<String, dynamic> get _data => <String, dynamic>{
        'fallbackUri': fallbackUri.toString(),
        'minimumVersion': minimumVersion,
        'packageName': packageName,
      };
}
