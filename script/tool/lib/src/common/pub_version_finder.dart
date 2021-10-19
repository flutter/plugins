// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

/// Finding version of [package] that is published on pub.
class PubVersionFinder {
  /// Constructor.
  ///
  /// Note: you should manually close the [httpClient] when done using the finder.
  PubVersionFinder({this.pubHost = defaultPubHost, required this.httpClient});

  /// The default pub host to use.
  static const String defaultPubHost = 'https://pub.dev';

  /// The pub host url, defaults to `https://pub.dev`.
  final String pubHost;

  /// The http client.
  ///
  /// You should manually close this client when done using this finder.
  final http.Client httpClient;

  /// Get the package version on pub.
  Future<PubVersionFinderResponse> getPackageVersion(
      {required String packageName}) async {
    assert(packageName.isNotEmpty);
    final Uri pubHostUri = Uri.parse(pubHost);
    final Uri url = pubHostUri.replace(path: '/packages/$packageName.json');
    final http.Response response = await httpClient.get(url);

    if (response.statusCode == 404) {
      return PubVersionFinderResponse(
          versions: <Version>[],
          result: PubVersionFinderResult.noPackageFound,
          httpResponse: response);
    } else if (response.statusCode != 200) {
      return PubVersionFinderResponse(
          versions: <Version>[],
          result: PubVersionFinderResult.fail,
          httpResponse: response);
    }
    final List<Version> versions =
        (json.decode(response.body)['versions'] as List<dynamic>)
            .map<Version>((final dynamic versionString) =>
                Version.parse(versionString as String))
            .toList();

    return PubVersionFinderResponse(
        versions: versions,
        result: PubVersionFinderResult.success,
        httpResponse: response);
  }
}

/// Represents a response for [PubVersionFinder].
class PubVersionFinderResponse {
  /// Constructor.
  PubVersionFinderResponse(
      {required this.versions,
      required this.result,
      required this.httpResponse}) {
    if (versions.isNotEmpty) {
      versions.sort((Version a, Version b) {
        // TODO(cyanglaz): Think about how to handle pre-release version with [Version.prioritize].
        // https://github.com/flutter/flutter/issues/82222
        return b.compareTo(a);
      });
    }
  }

  /// The versions found in [PubVersionFinder].
  ///
  /// This is sorted by largest to smallest, so the first element in the list is the largest version.
  /// Might be `null` if the [result] is not [PubVersionFinderResult.success].
  final List<Version> versions;

  /// The result of the version finder.
  final PubVersionFinderResult result;

  /// The response object of the http request.
  final http.Response httpResponse;
}

/// An enum representing the result of [PubVersionFinder].
enum PubVersionFinderResult {
  /// The version finder successfully found a version.
  success,

  /// The version finder failed to find a valid version.
  ///
  /// This might due to http connection errors or user errors.
  fail,

  /// The version finder failed to locate the package.
  ///
  /// This indicates the package is new.
  noPackageFound,
}
