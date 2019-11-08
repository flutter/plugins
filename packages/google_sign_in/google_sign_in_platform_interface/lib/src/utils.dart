import '../google_sign_in_platform_interface.dart';

/// Converts user data coming from native code into the proper platform interface type.
GoogleSignInUserData getUserDataFromMap(Map<String, dynamic> data) {
  if (data == null) {
    return null;
  }
  return GoogleSignInUserData(
      displayName: data['displayName'],
      email: data['email'],
      id: data['id'],
      photoUrl: data['photoUrl'],
      idToken: data['idToken']);
}

/// Converts token data coming from native code into the proper platform interface type.
GoogleSignInTokenData getTokenDataFromMap(Map<String, dynamic> data) {
  if (data == null) {
    return null;
  }
  return GoogleSignInTokenData(
    idToken: data['idToken'],
    accessToken: data['accessToken'],
  );
}
