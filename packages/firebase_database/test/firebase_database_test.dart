// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_database/firebase_database.dart';

void main() {
  group('$FirebaseDatabase', ()
  {
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
      expect(log, equals(<MethodCall>[
        new MethodCall('FirebaseDatabase#setPersistenceEnabled', { 'enabled': false }),
        new MethodCall('FirebaseDatabase#setPersistenceEnabled', { 'enabled': true }),
      ]));
    });

    test('setPersistentCacheSizeBytes', () async {
      await database.setPersistenceCacheSizeBytes(42);
      expect(log, equals(<MethodCall>[
        new MethodCall(
          'FirebaseDatabase#setPersistenceCacheSizeBytes',
          { 'cacheSize': 42 },
        ),
      ]));
    });

    test('goOnline', () async {
      await database.goOnline();
      expect(log, equals(<MethodCall>[
        new MethodCall('FirebaseDatabase#goOnline'),
      ]));
    });

    test('goOffline', () async {
      await database.goOffline();
      expect(log, equals(<MethodCall>[
        new MethodCall('FirebaseDatabase#goOffline'),
      ]));
    });

    test('purgeOutstandingWrites', () async {
      await database.purgeOutstandingWrites();
      expect(log, equals(<MethodCall>[
        new MethodCall('FirebaseDatabase#purgeOutstandingWrites'),
      ]));
    });

    group('$DatabaseReference', () {
      test('set', () async {
        dynamic value = {'hello': 'world'};
        int priority = 42;
        await database.reference().child('foo').set(value);
        await database.reference().child('bar').set(value, priority: priority);
        expect(log, equals(<MethodCall>[
          new MethodCall(
            'DatabaseReference#set',
            { 'path': 'foo', 'value': value, 'priority': null },
          ),
          new MethodCall(
            'DatabaseReference#set',
            { 'path': 'bar', 'value': value, 'priority': priority },
          ),
        ]));
      });

      test('setPriority', () async {
        int priority = 42;
        await database.reference().child('foo').setPriority(priority);
        expect(log, equals(<MethodCall>[
          new MethodCall(
            'DatabaseReference#setPriority',
            { 'path': 'foo', 'priority': priority },
          ),
        ]));
      });
    });

    group('$Query', () {
      // TODO(jackson): Write more tests for queries
      test('observing', () async {
        Query query = database.reference().child('foo').orderByChild('bar');
        StreamSubscription subscription = query.onValue.listen((_) {});
        await query.keepSynced(true);
        subscription.cancel();
        Map expectedParameters = <String, dynamic>{
          'orderBy': 'child',
          'orderByChildKey': 'bar',
        };
        expect(log, equals(<MethodCall>[
          new MethodCall(
            'Query#observe',
            { 'path': 'foo',
              'parameters': expectedParameters,
              'eventType': '_EventType.value'
            },
          ),
          new MethodCall(
            'Query#keepSynced',
            { 'path': 'foo', 'parameters': expectedParameters, 'value': true},
          ),
        ]));
      });
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel { }