part of firebase_dynamic_links;

class NavigationInfoParameters {
  NavigationInfoParameters([this.forcedRedirectEnabled]);

  final bool forcedRedirectEnabled;

  Map<String, dynamic> get _data => <String, dynamic>{
        'forcedRedirectEnabled': forcedRedirectEnabled,
      };
}
