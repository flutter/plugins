part of firebase_auth;

/// Interface representing a user's additional information
class AdditionalUserInfo {
  AdditionalUserInfo._(this._data);

  final Map<dynamic, dynamic> _data;

  /// Returns whether the user is new or existing
  bool get isNewUser => _data['isNewUser'];

  /// Returns the username if the provider is GitHub or Twitter
  String get getUsername => _data['getUsername'];

  /// Returns a Map containing IDP-specific user data if the provider is one of Facebook, GitHub, Google, Twitter, Microsoft, or Yahoo.
  Map<String, dynamic> get getProfile => _data['getProfile'];
}
