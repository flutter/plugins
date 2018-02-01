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
    final Transaction transaction = new Transaction(0);
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
          case 'DocumentReference#get':
            if (methodCall.arguments['path'] == 'foo/bar') {
              return <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, dynamic>{'key1': 'val1'}
              };
            }
            throw new PlatformException(code: 'UNKNOWN_PATH');
          case 'Firestore#runTransaction':
            return <String, dynamic>{'1': 3};
          case 'Transaction#get':
            return <String, dynamic>{
              'path': 'foo/bar',
              'data': <String, dynamic>{'key1': 'val1'}
            };
          case 'Transaction#set':
            return null;
          case 'Transaction#update':
            return null;
          case 'Transaction#delete':
            return null;
          default:
            return null;
        }
      });
      log.clear();
    });

    group('Transaction', () {
      test('runTransaction', () async {
        final Map<String, dynamic> result = await firestore.runTransaction(
            (Transaction tx) async {},
            timeout: new Duration(seconds: 3));

        expect(log, <Matcher>[
          isMethodCall('Firestore#runTransaction', arguments: <String, dynamic>{
            'transactionId': 0,
            'transactionTimeout': 3000
          }),
        ]);
        expect(result, equals(<String, dynamic>{'1': 3}));
      });

      test('get', () async {
        final DocumentReference documentReference =
            Firestore.instance.document('foo/bar');
        await transaction.get(documentReference);
        expect(log, <Matcher>[
          isMethodCall('Transaction#get', arguments: <String, dynamic>{
            'transactionId': 0,
            'path': documentReference.path
          })
        ]);
      });

      test('delete', () async {
        final DocumentReference documentReference =
            Firestore.instance.document('foo/bar');
        await transaction.delete(documentReference);
        expect(log, <Matcher>[
          isMethodCall('Transaction#delete', arguments: <String, dynamic>{
            'transactionId': 0,
            'path': documentReference.path
          })
        ]);
      });

      test('update', () async {
        final DocumentReference documentReference =
            Firestore.instance.document('foo/bar');
        final DocumentSnapshot documentSnapshot = await documentReference.get();
        final Map<String, dynamic> data = documentSnapshot.data;
        data['key2'] = 'val2';
        await transaction.set(documentReference, data);
        expect(log, <Matcher>[
          isMethodCall('DocumentReference#get',
              arguments: <String, dynamic>{'path': 'foo/bar'}),
          isMethodCall('Transaction#set', arguments: <String, dynamic>{
            'transactionId': 0,
            'path': documentReference.path,
            'data': <String, dynamic>{'key1': 'val1', 'key2': 'val2'}
          })
        ]);
      });

      test('set', () async {
        final DocumentReference documentReference =
            Firestore.instance.document('foo/bar');
        final DocumentSnapshot documentSnapshot = await documentReference.get();
        final Map<String, dynamic> data = documentSnapshot.data;
        data['key2'] = 'val2';
        await transaction.set(documentReference, data);
        expect(log, <Matcher>[
          isMethodCall('DocumentReference#get',
              arguments: <String, dynamic>{'path': 'foo/bar'}),
          isMethodCall('Transaction#set', arguments: <String, dynamic>{
            'transactionId': 0,
            'path': documentReference.path,
            'data': <String, dynamic>{'key1': 'val1', 'key2': 'val2'}
          })
        ]);
      });
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
                'orderBy': <List<dynamic>>[],
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
                  'orderBy': <List<dynamic>>[],
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
                  'orderBy': <List<dynamic>>[],
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
                  'orderBy': <List<dynamic>>[
                    <dynamic>['createdAt', false]
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
                'options': null,
              },
            ),
          ],
        );
      });
      test('merge set', () async {
        await collectionReference
            .document('bar')
            .setData(<String, String>{'bazKey': 'quxValue'}, SetOptions.merge);
        expect(SetOptions.merge, isNotNull);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DocumentReference#setData',
              arguments: <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, String>{'bazKey': 'quxValue'},
                'options': <String, bool>{'merge': true},
              },
            ),
          ],
        );
      });
      test('update', () async {
        await collectionReference
            .document('bar')
            .updateData(<String, String>{'bazKey': 'quxValue'});
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DocumentReference#updateData',
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
      test('get', () async {
        final DocumentSnapshot snapshot =
            await collectionReference.document('bar').get();
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'DocumentReference#get',
              arguments: <String, dynamic>{'path': 'foo/bar'},
            ),
          ]),
        );
        expect(snapshot.reference.path, equals('foo/bar'));
        expect(snapshot.data.containsKey('key1'), equals(true));
        expect(snapshot.data['key1'], equals('val1'));

        try {
          await collectionReference.document('baz').get();
        } on PlatformException catch (e) {
          expect(e.code, equals('UNKNOWN_PATH'));
        }
      });
      test('getCollection', () async {
        final CollectionReference colRef =
            collectionReference.document('bar').getCollection('baz');
        expect(colRef.path, 'foo/bar/baz');
      });
    });
  });
}
