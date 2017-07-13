class FakeSignInBackend {
  Map<String, dynamic> init(<String, dynamic> scopes) {
    print('fake init');
  }

  Map<String, String> getTokens(<String, dynamic> params) {
    print('get tokens');
  }

 Map<String, dynamic> signInSilently() {
    print('sign in silently');
 }

 Map<String, dynamic> signIn() {
    print('sign in');
 }

 Map<String, dynamic> disconnect() {
    print('disconnect');
 }
}