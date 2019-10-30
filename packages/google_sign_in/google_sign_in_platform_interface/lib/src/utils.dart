import '../google_sign_in_platform_interface.dart';

GoogleSignInUserData nativeUserDataToPluginUserData(Map<String, dynamic> data) {
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

GoogleSignInTokenData nativeTokenDataToPluginTokenData(
    Map<String, dynamic> data) {
  if (data == null) {
    return null;
  }
  return GoogleSignInTokenData(
    idToken: data['idToken'],
    accessToken: data['accessToken'],
  );
}
