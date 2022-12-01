// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$GoogleMapsPlacesMethodChannel()', () {
    final GoogleMapsPlacesMethodChannel plugin =
        GoogleMapsPlacesMethodChannel();

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      plugin.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      log.clear();
    });

    group('#findAutocompletePredictions', () {
      test('passes the required types correctly', () async {
        await plugin.findAutocompletePredictions(query: mockQuery);

        expectMethodCall(
          log,
          'findAutocompletePredictions',
          arguments: <String, dynamic>{
            'query': mockQuery,
            'countries': null,
            'typeFilter': null,
            'origin': null,
            'locationBias': null,
            'locationRestriction': null,
            'refreshToken': null
          },
        );
      });

      test('passes the optional parameters with location bias', () async {
        await plugin.findAutocompletePredictions(
            query: mockQuery,
            locationBias: mockLocationBias,
            origin: mockOrigin,
            countries: mockCountries,
            typeFilter: mockTypeFilters);

        expectMethodCall(
          log,
          'findAutocompletePredictions',
          arguments: <String, dynamic>{
            'query': mockQuery,
            'countries': <String>['fi'],
            'typeFilter': <int>[0],
            'origin': <double>[65.0121, 25.4651],
            'locationBias': <List<double>>[
              <double>[60.4518, 22.2666],
              <double>[70.0821, 27.8718]
            ],
            'locationRestriction': null,
            'refreshToken': null
          },
        );
      });
      test('passes the optional parameters with location restriction',
          () async {
        await plugin.findAutocompletePredictions(
            query: mockQuery,
            locationRestriction: mockLocationRestriction,
            origin: mockOrigin,
            countries: mockCountries,
            typeFilter: mockTypeFilters,
            refreshToken: true);

        expectMethodCall(
          log,
          'findAutocompletePredictions',
          arguments: <String, dynamic>{
            'query': mockQuery,
            'countries': <String>['fi'],
            'typeFilter': <int>[0],
            'origin': <double>[65.0121, 25.4651],
            'locationBias': null,
            'locationRestriction': <List<double>>[
              <double>[63.4518, 23.2666],
              <double>[67.0821, 26.8718]
            ],
            'refreshToken': true
          },
        );
      });
      test('throws for location bias and restriction', () async {
        await expectLater(
            plugin.findAutocompletePredictions(
                query: mockQuery,
                locationBias: mockLocationBias,
                locationRestriction: mockLocationRestriction),
            throwsAssertionError);
      });

      test('throws for multiple typefilters', () async {
        await expectLater(
            plugin.findAutocompletePredictions(
                query: mockQuery,
                typeFilter: <TypeFilter>[
                  TypeFilter.address,
                  TypeFilter.cities
                ]),
            throwsAssertionError);
      });
    });
  });
}

void expectMethodCall(
  List<MethodCall> log,
  String methodName, {
  Map<String, dynamic>? arguments,
}) {
  expect(log, <Matcher>[isMethodCall(methodName, arguments: arguments)]);
}
