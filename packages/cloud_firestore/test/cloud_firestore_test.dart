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
    const Map<String, dynamic> kMockDocumentSnapshotData =
        const <String, dynamic>{'1': 2};

    setUp(() async {
      mockHandleId = 0;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            final int handle = mockHandleId++;
            BinaryMessages.handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                new MethodCall('QuerySnapshot', <String, dynamic>{
                  'handle': handle,
                  'paths': <String>["${methodCall.arguments['path']}/0"],
                  'documents': <dynamic>[kMockDocumentSnapshotData],
                  'documentChanges': <dynamic>[
                    <String, dynamic>{
                      'oldIndex': -1,
                      'newIndex': 0,
                      'type': 'DocumentChangeType.added',
                      'document': kMockDocumentSnapshotData,
                    },
                  ],
                }),
              ),
              (_) {},
            );
            return handle;
          case 'Query#addDocumentListener':
            final int handle = mockHandleId++;
            BinaryMessages.handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                new MethodCall('DocumentSnapshot', <String, dynamic>{
                  'handle': handle,
                  'path': methodCall.arguments['path'],
                  'data': kMockDocumentSnapshotData,
                }),
              ),
              (_) {},
            );
            return handle;
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
        final QuerySnapshot snapshot =
            await collectionReference.snapshots.first;
        final DocumentSnapshot document = snapshot.documents[0];
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));
        // Flush the async removeListener call
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
        final DocumentSnapshot snapshot =
            await Firestore.instance.document('path/to/foo').snapshots.first;
        expect(snapshot.documentID, equals('foo'));
        expect(snapshot.reference.path, equals('path/to/foo'));
        expect(snapshot.data, equals(kMockDocumentSnapshotData));
        // Flush the async removeListener call
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'Query#addDocumentListener',
              arguments: <String, dynamic>{
                'path': 'path/to/foo',
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
      test('getCollection', () async {
        final CollectionReference colRef =
            collectionReference.document('bar').getCollection('baz');
        expect(colRef.path, 'foo/bar/baz');
      });
    });
  });
}
