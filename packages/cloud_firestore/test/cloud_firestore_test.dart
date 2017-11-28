// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Firestore', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/cloud_firestore',
    );

    int mockHandleId = 0;
    final Firestore firestore = Firestore.instance;
    final List<MethodCall> log = <MethodCall>[];
    final CollectionReference collectionReference = firestore.collection('foo');

    setUp(() async {
      mockHandleId = 0;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            return mockHandleId++;
          case 'Query#addDocumentListener':
            return mockHandleId++;
          case 'DocumentReference#setData':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    group('CollectionsReference', () {
      test('listen', () async {
        final StreamSubscription<QuerySnapshot> subscription =
            collectionReference.snapshots
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.ZERO);
        expect(log, <Matcher>[
          isMethodCall(
            'Query#addSnapshotListener',
            arguments: <String, dynamic>{
              'path': 'foo',
              'parameters': <String, dynamic>{
                'where': <List<dynamic>>[],
              }
            },
          ),
          isMethodCall(
            'Query#removeListener',
            arguments: <String, dynamic>{'handle': 0},
          ),
        ]);
      });
      test('where', () async {
        final StreamSubscription<QuerySnapshot> subscription =
            collectionReference
                .where('createdAt', isLessThan: 100)
                .snapshots
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'Query#addSnapshotListener',
              arguments: <String, dynamic>{
                'path': 'foo',
                'parameters': <String, dynamic>{
                  'where': <List<dynamic>>[
                    <dynamic>['createdAt', '<', 100],
                  ],
                }
              },
            ),
            isMethodCall(
              'Query#removeListener',
              arguments: <String, dynamic>{'handle': 0},
            ),
          ]),
        );
      });
      test('where field isNull', () async {
        final StreamSubscription<QuerySnapshot> subscription =
            collectionReference
                .where('profile', isNull: true)
                .snapshots
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'Query#addSnapshotListener',
              arguments: <String, dynamic>{
                'path': 'foo',
                'parameters': <String, dynamic>{
                  'where': <List<dynamic>>[
                    <dynamic>['profile', '==', null],
                  ],
                }
              },
            ),
            isMethodCall(
              'Query#removeListener',
              arguments: <String, dynamic>{'handle': 0},
            ),
          ]),
        );
      });
      test('orderBy', () async {
        final StreamSubscription<QuerySnapshot> subscription =
            collectionReference
                .orderBy('createdAt')
                .snapshots
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'Query#addSnapshotListener',
              arguments: <String, dynamic>{
                'path': 'foo',
                'parameters': <String, dynamic>{
                  'where': <List<dynamic>>[],
                  'orderBy': <dynamic>['createdAt', false],
                }
              },
            ),
            isMethodCall(
              'Query#removeListener',
              arguments: <String, dynamic>{'handle': 0},
            ),
          ]),
        );
      });
    });

    group('DocumentReference', () {
      test('listen', () async {
        final StreamSubscription<DocumentSnapshot> subscription =
            Firestore.instance.document('foo').snapshots.listen(
                  (DocumentSnapshot querySnapshot) {},
                );
        subscription.cancel();
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'Query#addDocumentListener',
              arguments: <String, dynamic>{
                'path': 'foo',
              },
            ),
            isMethodCall(
              'Query#removeListener',
              arguments: <String, dynamic>{'handle': 0},
            ),
          ],
        );
      });
      test('set', () async {
        await collectionReference
            .document('bar')
            .setData(<String, String>{'bazKey': 'quxValue'});
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DocumentReference#setData',
              arguments: <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, String>{'bazKey': 'quxValue'},
              },
            ),
          ],
        );
      });
      test('delete', () async {
        await collectionReference.document('bar').delete();
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'DocumentReference#delete',
              arguments: <String, dynamic>{'path': 'foo/bar'},
            ),
          ]),
        );
      });
    });
  });
}
