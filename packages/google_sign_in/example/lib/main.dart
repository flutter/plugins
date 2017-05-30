import 'dart:async';
import 'dart:convert' show JSON;

import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

void main() {
  runApp(
      new MaterialApp(
          title: 'Google Sign In',
          home: new SignInDemo(),
      ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => new SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;
  String _contactText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<Null> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    http.Response response = await http.get(
        'https://people.googleapis.com/v1/people/me/connections' +
            '?requestMask.includeField=person.names',
        headers: await _currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} " +
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    Map<String, dynamic> data = JSON.decode(response.body);
    String namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    List<Map<String, dynamic>> connections = data['connections'];
    Map<String, dynamic> contact = connections?.firstWhere(
            (Map<String, dynamic> contact) => contact['names'] != null,
        orElse: () => null,
    );
    if (contact != null) {
      Map<String, dynamic> name = contact['names'].firstWhere(
              (Map<String, dynamic> name) => name['displayName'] != null,
          orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<Null> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleSignOut() async {
    _googleSignIn.disconnect();
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new ListTile(
                leading: new GoogleUserCircleAvatar(_currentUser.photoUrl),
                title: new Text(_currentUser.displayName),
                subtitle: new Text(_currentUser.email),
            ),
            new Text("Signed in successfully."),
            new Text(_contactText),
            new RaisedButton(
                child: new Text('SIGN OUT'),
                onPressed: _handleSignOut,
            ),
            new RaisedButton(
                child: new Text('REFRESH'),
                onPressed: _handleGetContact,
            ),
          ],
      );
    } else {
      return new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new Text("You are not currently signed in."),
            new RaisedButton(
                child: new Text('SIGN IN'),
                onPressed: _handleSignIn,
            ),
          ],
      );
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text('Google Sign In'),
        ),
        body: new ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: _buildBody(),
        ));
  }
}
