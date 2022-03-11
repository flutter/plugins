// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// A URL load request that is independent of protocol or URL scheme.
///
/// Wraps [NSUrlRequest](https://developer.apple.com/documentation/foundation/nsurlrequest?language=objc).
@immutable
class NSUrlRequest {
  /// Constructs an [NSUrlRequest].
  const NSUrlRequest({
    required this.url,
    this.httpMethod,
    this.httpBody,
    this.allHttpHeaderFields = const <String, String>{},
  });

  /// The URL being requested.
  final String url;

  /// The HTTP request method.
  ///
  /// The default HTTP method is “GET”.
  final String? httpMethod;

  /// Data sent as the message body of a request, as in an HTTP POST request.
  final Uint8List? httpBody;

  /// All of the HTTP header fields for a request.
  final Map<String, String> allHttpHeaderFields;
}

/// Information about an error condition.
///
/// Wraps [NSError](https://developer.apple.com/documentation/foundation/nserror?language=objc).
@immutable
class NSError {
  /// Constructs an [NSError].
  const NSError({
    required this.code,
    required this.domain,
    required this.localizedDescription,
  });

  /// The error code.
  ///
  /// Note that errors are domain-specific.
  final int code;

  /// A string containing the error domain.
  final String domain;

  /// A string containing the localized description of the error.
  final String localizedDescription;
}
