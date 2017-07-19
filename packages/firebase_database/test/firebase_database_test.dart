// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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
        switch (methodCall.method) {
          case 'Query#observe':
            return mockHandleId++;
          case 'FirebaseDatabase#setPersistenceEnabled':
            return true;
          case 'FirebaseDatabase#setPersistenceCacheSizeBytes':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    test('setPersistenceEnabled', () async {
      expect(await database.setPersistenceEnabled(false), true);
      expect(await database.setPersistenceEnabled(true), true);
      expect(
        log,
        equals(<MethodCall>[
          const MethodCall('FirebaseDatabase#setPersistenceEnabled', false),
          const MethodCall('FirebaseDatabase#setPersistenceEnabled', true),
        ]),
      );
    });

    test('setPersistentCacheSizeBytes', () async {
      expect(await database.setPersistenceCacheSizeBytes(42), true);
      expect(
        log,
        equals(<MethodCall>[
          const MethodCall('FirebaseDatabase#setPersistenceCacheSizeBytes', 42),
        ]),
      );
    });

    test('goOnline', () async {
      await database.goOnline();
      expect(
        log,
        equals(<MethodCall>[
          const MethodCall('FirebaseDatabase#goOnline'),
        ]),
      );
    });

    test('goOffline', () async {
      await database.goOffline();
      expect(
        log,
        equals(<MethodCall>[
          const MethodCall('FirebaseDatabase#goOffline'),
        ]),
      );
    });

    test('purgeOutstandingWrites', () async {
      await database.purgeOutstandingWrites();
      expect(
        log,
        equals(<MethodCall>[
          const MethodCall('FirebaseDatabase#purgeOutstandingWrites'),
        ]),
      );
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
          ]),
        );
      });
      test('update', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        await database.reference().child("foo").update(value);
        expect(
          log,
          equals(<MethodCall>[
            new MethodCall(
              'DatabaseReference#update',
              <String, dynamic>{'path': 'foo', 'value': value},
            ),
          ]),
        );
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
          ]),
        );
      });
    });

    group('$Query', () {
      // TODO(jackson): Write more tests for queries
      test('observing', () async {
        final int startAt = 42;
        final String path = 'foo';
        final String childKey = 'bar';
        final bool endAt = true;
        final String endAtKey = 'baz';
        final Query query = database
            .reference()
            .child(path)
            .orderByChild(childKey)
            .startAt(startAt)
            .endAt(endAt, key: endAtKey);
        final StreamSubscription<Event> subscription =
            query.onValue.listen((_) {});
        await query.keepSynced(true);
        subscription.cancel();
        final Map<String, dynamic> expectedParameters = <String, dynamic>{
          'orderBy': 'child',
          'orderByChildKey': childKey,
          'startAt': startAt,
          'endAt': endAt,
          'endAtKey': endAtKey,
        };
        expect(
          log,
          equals(<MethodCall>[
            new MethodCall(
              'Query#observe',
              <String, dynamic>{
                'path': path,
                'parameters': expectedParameters,
                'eventType': '_EventType.value'
              },
            ),
            new MethodCall(
              'Query#keepSynced',
              <String, dynamic>{
                'path': path,
                'parameters': expectedParameters,
                'value': true
              },
            ),
          ]),
        );
      });
    });
  });
}
