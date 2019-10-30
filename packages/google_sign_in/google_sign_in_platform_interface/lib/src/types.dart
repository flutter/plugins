import 'package:quiver_hashcode/hashcode.dart';

enum SignInOption { standard, games }

class GoogleSignInUserData {
  GoogleSignInUserData(
      {this.displayName, this.email, this.id, this.photoUrl, this.idToken});
  String displayName;
  String email;
  String id;
  String photoUrl;
  String idToken;

  @override
  int get hashCode =>
      hashObjects(<String>[displayName, email, id, photoUrl, idToken]);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInUserData) return false;
    return other.displayName == displayName &&
        other.email == email &&
        other.id == id &&
        other.photoUrl == photoUrl &&
        other.idToken == idToken;
  }
}

class GoogleSignInTokenData {
  GoogleSignInTokenData({this.idToken, this.accessToken});
  String idToken;
  String accessToken;

  @override
  int get hashCode => hash2(idToken, accessToken);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInTokenData) return false;
    return other.idToken == idToken && other.accessToken == accessToken;
  }
}
