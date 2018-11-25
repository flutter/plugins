// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_auth;

/// Represents the credentials returned by calling the `getCredential` method of
/// an auth provider.
class AuthCredential {
  AuthCredential._(this._provider, this._data);
  final String _provider;
  final Map<String, String> _data;
}
