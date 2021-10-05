// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_plugin_tools/src/common/pub_version_finder.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('Package does not exist.', () async {
    final MockClient mockClient = MockClient((http.Request request) async {
      return http.Response('', 404);
    });
    final PubVersionFinder finder = PubVersionFinder(httpClient: mockClient);
    final PubVersionFinderResponse response =
        await finder.getPackageVersion(packageName: 'some_package');

    expect(response.versions, isEmpty);
    expect(response.result, PubVersionFinderResult.noPackageFound);
    expect(response.httpResponse.statusCode, 404);
    expect(response.httpResponse.body, '');
  });

  test('HTTP error when getting versions from pub', () async {
    final MockClient mockClient = MockClient((http.Request request) async {
      return http.Response('', 400);
    });
    final PubVersionFinder finder = PubVersionFinder(httpClient: mockClient);
    final PubVersionFinderResponse response =
        await finder.getPackageVersion(packageName: 'some_package');

    expect(response.versions, isEmpty);
    expect(response.result, PubVersionFinderResult.fail);
    expect(response.httpResponse.statusCode, 400);
    expect(response.httpResponse.body, '');
  });

  test('Get a correct list of versions when http response is OK.', () async {
    const Map<String, dynamic> httpResponse = <String, dynamic>{
      'name': 'some_package',
      'versions': <String>[
        '0.0.1',
        '0.0.2',
        '0.0.2+2',
        '0.1.1',
        '0.0.1+1',
        '0.1.0',
        '0.2.0',
        '0.1.0+1',
        '0.0.2+1',
        '2.0.0',
        '1.2.0',
        '1.0.0',
      ],
    };
    final MockClient mockClient = MockClient((http.Request request) async {
      return http.Response(json.encode(httpResponse), 200);
    });
    final PubVersionFinder finder = PubVersionFinder(httpClient: mockClient);
    final PubVersionFinderResponse response =
        await finder.getPackageVersion(packageName: 'some_package');

    expect(response.versions, <Version>[
      Version.parse('2.0.0'),
      Version.parse('1.2.0'),
      Version.parse('1.0.0'),
      Version.parse('0.2.0'),
      Version.parse('0.1.1'),
      Version.parse('0.1.0+1'),
      Version.parse('0.1.0'),
      Version.parse('0.0.2+2'),
      Version.parse('0.0.2+1'),
      Version.parse('0.0.2'),
      Version.parse('0.0.1+1'),
      Version.parse('0.0.1'),
    ]);
    expect(response.result, PubVersionFinderResult.success);
    expect(response.httpResponse.statusCode, 200);
    expect(response.httpResponse.body, json.encode(httpResponse));
  });
}

class MockProcessResult extends Mock implements ProcessResult {}
