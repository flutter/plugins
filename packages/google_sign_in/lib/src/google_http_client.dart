// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../google_sign_in.dart';

/// Encapsulation of the fields that represent a Google Http Client.
class GoogleHttpClient extends IOClient {
  GoogleHttpClient._(this._headers) : super();

  Map<String, String> _headers;

  /// Add authentication headers to the request.
  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  /// Add authentication headers to the newly created request.
  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
