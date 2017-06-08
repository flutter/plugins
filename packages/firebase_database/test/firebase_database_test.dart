// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_database/firebase_database.dart';

void main() {
  group('$FirebaseDatabase', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/firebase_database',
    );

    int mockHandleId = 0;
    final List<MethodCall> log = <MethodCall>[];
    final FirebaseDatabase database = FirebaseDatabase.instance;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'Query#observe') {
          return mockHandleId++;
        }
        return null;
      });
      log.clear();
    });

    test('setPersistenceEnabled', () async {
      await database.setPersistenceEnabled(false);
      await database.setPersistenceEnabled(true);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('FirebaseDatabase#setPersistenceEnabled',
                <String, dynamic>{'enabled': false}),
            new MethodCall('FirebaseDatabase#setPersistenceEnabled',
                <String, dynamic>{'enabled': true}),
          ]));
    });

    test('setPersistentCacheSizeBytes', () async {
      await database.setPersistenceCacheSizeBytes(42);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall(
              'FirebaseDatabase#setPersistenceCacheSizeBytes',
              <String, dynamic>{'cacheSize': 42},
            ),
          ]));
    });

    test('goOnline', () async {
      await database.goOnline();
      expect(
          log,
          equals(<MethodCall>[
            const MethodCall('FirebaseDatabase#goOnline'),
          ]));
    });

    test('goOffline', () async {
      await database.goOffline();
      expect(
          log,
          equals(<MethodCall>[
            const MethodCall('FirebaseDatabase#goOffline'),
          ]));
    });

    test('purgeOutstandingWrites', () async {
      await database.purgeOutstandingWrites();
      expect(
          log,
          equals(<MethodCall>[
            const MethodCall('FirebaseDatabase#purgeOutstandingWrites'),
          ]));
    });

    group('$DatabaseReference', () {
      test('set', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        final int priority = 42;
        await database.reference().child('foo').set(value);
        await database.reference().child('bar').set(value, priority: priority);
        expect(
            log,
            equals(<MethodCall>[
              new MethodCall(
                'DatabaseReference#set',
                <String, dynamic>{
                  'path': 'foo',
                  'value': value,
                  'priority': null
                },
              ),
              new MethodCall(
                'DatabaseReference#set',
                <String, dynamic>{
                  'path': 'bar',
                  'value': value,
                  'priority': priority
                },
              ),
            ]));
      });

      test('setPriority', () async {
        final int priority = 42;
        await database.reference().child('foo').setPriority(priority);
        expect(
            log,
            equals(<MethodCall>[
              new MethodCall(
                'DatabaseReference#setPriority',
                <String, dynamic>{'path': 'foo', 'priority': priority},
              ),
            ]));
      });
    });

    group('$Query', () {
      // TODO(jackson): Write more tests for queries
      test('observing', () async {
        final Query query =
            database.reference().child('foo').orderByChild('bar');
        final StreamSubscription<Event> subscription =
            query.onValue.listen((_) {});
        await query.keepSynced(true);
        subscription.cancel();
        final Map<String, dynamic> expectedParameters = <String, dynamic>{
          'orderBy': 'child',
          'orderByChildKey': 'bar',
        };
        expect(
            log,
            equals(<MethodCall>[
              new MethodCall(
                'Query#observe',
                <String, dynamic>{
                  'path': 'foo',
                  'parameters': expectedParameters,
                  'eventType': '_EventType.value'
                },
              ),
              new MethodCall(
                'Query#keepSynced',
                <String, dynamic>{
                  'path': 'foo',
                  'parameters': expectedParameters,
                  'value': true
                },
              ),
            ]));
      });
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
