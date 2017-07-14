import 'dart:async';
import 'package:flutter/services.dart';

class FakeSignInBackend {
  Map<String, String> _currentUser = <String, String>{};

  void _init(Map<String, dynamic> args) {}

  void setUser(Map<String, String> userData) {
    _currentUser = {
      'displayName': userData['displayName'],
      'email': userData['email'],
      'id': userData['id'],
      'photoUrl': userData['photoUrl'],
      'idToken': userData['idToken']
    };
  }

  Map<String, String> getTokens(Map<String, String> args) {
    String email = args['email'];
    return <String, String>{
      'idToken': _currentUser['idToken']
    };
  }

  Map<String, dynamic> signIn() {
    return _currentUser;
  }

  Map<String, dynamic> signInSilently() {
    return signIn();
 }
 Map<String, dynamic> disconnect() {
   _currentUser = <String, String>{};
   return _currentUser;
 }

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    print('*** handleMethodCall');
    switch(methodCall.method) {
      case 'init': return _init(methodCall.arguments);
      case 'getTokens': return getTokens(methodCall.arguments);
      case 'signIn': return signIn();
      case 'signInSilently': return signInSilently();
      case 'disconnect': return disconnect();
    }
 }
}