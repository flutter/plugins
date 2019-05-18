part of firebase_auth;

/// Interface representing a user's additional information
class AdditionalUserInfo {
  AdditionalUserInfo._(this._data);

  final Map<dynamic, dynamic> _data;

  bool get isNewUser => _data['isNewUser'];

  String get getUsername => _data['getUsername'];

  Map<String, dynamic> get getProfile => _data['getProfile'];
}
