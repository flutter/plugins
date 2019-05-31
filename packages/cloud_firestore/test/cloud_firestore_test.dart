// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Firestore', () {
    int mockHandleId = 0;
    FirebaseApp app;
    Firestore firestore;
    final List<MethodCall> log = <MethodCall>[];
    CollectionReference collectionReference;
    Transaction transaction;
    const Map<String, dynamic> kMockDocumentSnapshotData = <String, dynamic>{
      '1': 2
    };

    setUp(() async {
      mockHandleId = 0;
      // Required for FirebaseApp.configure
      FirebaseApp.channel.setMockMethodCallHandler(
        (MethodCall methodCall) async {},
      );
      app = await FirebaseApp.configure(
        name: 'testApp',
        options: const FirebaseOptions(
          googleAppID: '1:1234567890:ios:42424242424242',
          gcmSenderID: '1234567890',
        ),
      );
      firestore = new Firestore(app: app);
      collectionReference = firestore.collection('foo');
      transaction = new Transaction(0, firestore);
      Firestore.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            final int handle = mockHandleId++;
            // Wait before sending a message back.
            // Otherwise the first request didn't have the time to finish.
<<<<<<< HEAD
            new Future<void>.delayed(Duration.zero).then<void>((_) {
=======
            Future<void>.delayed(Duration.zero).then<void>((_) {
              // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
              // https://github.com/flutter/flutter/issues/33446
              // ignore: deprecated_member_use
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
              BinaryMessages.handlePlatformMessage(
                Firestore.channel.name,
                Firestore.channel.codec.encodeMethodCall(
                  new MethodCall('QuerySnapshot', <String, dynamic>{
                    'app': app.name,
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
            });
            return handle;
          case 'Query#addDocumentListener':
            final int handle = mockHandleId++;
            // Wait before sending a message back.
            // Otherwise the first request didn't have the time to finish.
<<<<<<< HEAD
            new Future<void>.delayed(Duration.zero).then<void>((_) {
=======
            Future<void>.delayed(Duration.zero).then<void>((_) {
              // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
              // https://github.com/flutter/flutter/issues/33446
              // ignore: deprecated_member_use
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
              BinaryMessages.handlePlatformMessage(
                Firestore.channel.name,
                Firestore.channel.codec.encodeMethodCall(
                  new MethodCall('DocumentSnapshot', <String, dynamic>{
                    'handle': handle,
                    'path': methodCall.arguments['path'],
                    'data': kMockDocumentSnapshotData,
                  }),
                ),
                (_) {},
              );
            });
            return handle;
          case 'Query#getDocuments':
            return <String, dynamic>{
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
            };
          case 'DocumentReference#setData':
            return true;
          case 'DocumentReference#get':
            if (methodCall.arguments['path'] == 'foo/bar') {
              return <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, dynamic>{'key1': 'val1'}
              };
            } else if (methodCall.arguments['path'] == 'foo/notExists') {
              return <String, dynamic>{'path': 'foo/notExists', 'data': null};
            }
            throw new PlatformException(code: 'UNKNOWN_PATH');
          case 'Firestore#runTransaction':
            return <String, dynamic>{'1': 3};
          case 'Transaction#get':
            if (methodCall.arguments['path'] == 'foo/bar') {
              return <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, dynamic>{'key1': 'val1'}
              };
            } else if (methodCall.arguments['path'] == 'foo/notExists') {
              return <String, dynamic>{'path': 'foo/notExists', 'data': null};
            }
            throw new PlatformException(code: 'UNKNOWN_PATH');
          case 'Transaction#set':
            return null;
          case 'Transaction#update':
            return null;
          case 'Transaction#delete':
            return null;
          case 'WriteBatch#create':
            return 1;
          default:
            return null;
        }
      });
      log.clear();
    });

    test('multiple apps', () async {
      expect(Firestore.instance, equals(new Firestore()));
      final FirebaseApp app = new FirebaseApp(name: firestore.app.name);
      expect(firestore, equals(new Firestore(app: app)));
    });

    group('Transaction', () {
      test('runTransaction', () async {
        final Map<String, dynamic> result = await firestore.runTransaction(
            (Transaction tx) async {},
            timeout: const Duration(seconds: 3));

        expect(log, <Matcher>[
          isMethodCall('Firestore#runTransaction', arguments: <String, dynamic>{
            'app': app.name,
            'transactionId': 0,
            'transactionTimeout': 3000
          }),
        ]);
        expect(result, equals(<String, dynamic>{'1': 3}));
      });

      test('get', () async {
        final DocumentReference documentReference =
            firestore.document('foo/bar');
        await transaction.get(documentReference);
        expect(log, <Matcher>[
          isMethodCall('Transaction#get', arguments: <String, dynamic>{
            'app': app.name,
            'transactionId': 0,
            'path': documentReference.path
          })
        ]);
      });

      test('get notExists', () async {
        final DocumentReference documentReference =
            firestore.document('foo/notExists');
        await transaction.get(documentReference);
        expect(log, <Matcher>[
          isMethodCall('Transaction#get', arguments: <String, dynamic>{
            'app': app.name,
            'transactionId': 0,
            'path': documentReference.path
          })
        ]);
      });

      test('delete', () async {
        final DocumentReference documentReference =
            firestore.document('foo/bar');
        await transaction.delete(documentReference);
        expect(log, <Matcher>[
          isMethodCall('Transaction#delete', arguments: <String, dynamic>{
            'app': app.name,
            'transactionId': 0,
            'path': documentReference.path
          })
        ]);
      });

      test('update', () async {
        final DocumentReference documentReference =
            firestore.document('foo/bar');
        final DocumentSnapshot documentSnapshot = await documentReference.get();
        final Map<String, dynamic> data = documentSnapshot.data;
        data['key2'] = 'val2';
        await transaction.set(documentReference, data);
        expect(log, <Matcher>[
          isMethodCall('DocumentReference#get', arguments: <String, dynamic>{
            'app': app.name,
            'path': 'foo/bar',
            'source': 'default',
          }),
          isMethodCall('Transaction#set', arguments: <String, dynamic>{
            'app': app.name,
            'transactionId': 0,
            'path': documentReference.path,
            'data': <String, dynamic>{'key1': 'val1', 'key2': 'val2'}
          })
        ]);
      });

      test('set', () async {
        final DocumentReference documentReference =
            firestore.document('foo/bar');
        final DocumentSnapshot documentSnapshot = await documentReference.get();
        final Map<String, dynamic> data = documentSnapshot.data;
        data['key2'] = 'val2';
        await transaction.set(documentReference, data);
        expect(log, <Matcher>[
          isMethodCall('DocumentReference#get', arguments: <String, dynamic>{
            'app': app.name,
            'path': 'foo/bar',
            'source': 'default',
          }),
          isMethodCall('Transaction#set', arguments: <String, dynamic>{
            'app': app.name,
            'transactionId': 0,
            'path': documentReference.path,
            'data': <String, dynamic>{'key1': 'val1', 'key2': 'val2'}
          })
        ]);
      });
    });

    group('Blob', () {
      test('hashCode equality', () async {
        final Uint8List bytesA = new Uint8List(8);
        bytesA.setAll(0, <int>[0, 2, 4, 6, 8, 10, 12, 14]);
        final Blob a = new Blob(bytesA);
        final Uint8List bytesB = new Uint8List(8);
        bytesB.setAll(0, <int>[0, 2, 4, 6, 8, 10, 12, 14]);
        final Blob b = new Blob(bytesB);
        expect(a.hashCode == b.hashCode, isTrue);
      });
      test('hashCode not equal', () async {
        final Uint8List bytesA = new Uint8List(8);
        bytesA.setAll(0, <int>[0, 2, 4, 6, 8, 10, 12, 14]);
        final Blob a = new Blob(bytesA);
        final Uint8List bytesB = new Uint8List(8);
        bytesB.setAll(0, <int>[1, 2, 4, 6, 8, 10, 12, 14]);
        final Blob b = new Blob(bytesB);
        expect(a.hashCode == b.hashCode, isFalse);
      });
    });
    group('CollectionsReference', () {
      test('id', () async {
        expect(collectionReference.id, equals('foo'));
      });
      test('parent', () async {
        final DocumentReference docRef = collectionReference.document('bar');
        expect(docRef.parent().id, equals('foo'));
        expect(collectionReference.parent(), isNull);
      });
      test('path', () async {
        expect(collectionReference.path, equals('foo'));
      });
      test('listen', () async {
        final QuerySnapshot snapshot =
            await collectionReference.snapshots().first;
        final DocumentSnapshot document = snapshot.documents[0];
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));
        // Flush the async removeListener call
        await new Future<Null>.delayed(Duration.zero);
        expect(log, <Matcher>[
          isMethodCall(
            'Query#addSnapshotListener',
            arguments: <String, dynamic>{
              'app': app.name,
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
                .snapshots()
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.zero);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'Query#addSnapshotListener',
              arguments: <String, dynamic>{
                'app': app.name,
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
                .snapshots()
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.zero);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'Query#addSnapshotListener',
              arguments: <String, dynamic>{
                'app': app.name,
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
                .snapshots()
                .listen((QuerySnapshot querySnapshot) {});
        subscription.cancel();
        await new Future<Null>.delayed(Duration.zero);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'Query#addSnapshotListener',
              arguments: <String, dynamic>{
                'app': app.name,
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
            await firestore.document('path/to/foo').snapshots().first;
        expect(snapshot.documentID, equals('foo'));
        expect(snapshot.reference.path, equals('path/to/foo'));
        expect(snapshot.data, equals(kMockDocumentSnapshotData));
        // Flush the async removeListener call
        await new Future<Null>.delayed(Duration.zero);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'Query#addDocumentListener',
              arguments: <String, dynamic>{
                'app': app.name,
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
                'app': app.name,
                'path': 'foo/bar',
                'data': <String, String>{'bazKey': 'quxValue'},
                'options': <String, bool>{'merge': false},
              },
            ),
          ],
        );
      });
      test('merge set', () async {
        await collectionReference
            .document('bar')
            .setData(<String, String>{'bazKey': 'quxValue'}, merge: true);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DocumentReference#setData',
              arguments: <String, dynamic>{
                'app': app.name,
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
                'app': app.name,
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
              arguments: <String, dynamic>{
                'app': app.name,
                'path': 'foo/bar',
              },
            ),
          ]),
        );
      });
      test('get', () async {
        final DocumentSnapshot snapshot =
<<<<<<< HEAD
            await collectionReference.document('bar').get();
=======
            await collectionReference.document('bar').get(source: Source.cache);
        expect(snapshot.reference.firestore, firestore);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'DocumentReference#get',
              arguments: <String, dynamic>{
                'app': app.name,
                'path': 'foo/bar',
                'source': 'cache',
              },
            ),
          ]),
        );
        log.clear();
        expect(snapshot.reference.path, equals('foo/bar'));
        expect(snapshot.data.containsKey('key1'), equals(true));
        expect(snapshot.data['key1'], equals('val1'));
        expect(snapshot.exists, isTrue);

        final DocumentSnapshot snapshot2 = await collectionReference
            .document('notExists')
            .get(source: Source.serverAndCache);
        expect(snapshot2.data, isNull);
        expect(snapshot2.exists, isFalse);
        expect(
          log,
          equals(<Matcher>[
            isMethodCall(
              'DocumentReference#get',
              arguments: <String, dynamic>{
                'app': app.name,
                'path': 'foo/notExists',
                'source': 'default',
              },
            ),
          ]),
        );

        try {
          await collectionReference.document('baz').get();
        } on PlatformException catch (e) {
          expect(e.code, equals('UNKNOWN_PATH'));
        }
      });
      test('collection', () async {
        final CollectionReference colRef =
            collectionReference.document('bar').collection('baz');
        expect(colRef.path, equals('foo/bar/baz'));
      });
      test('parent', () async {
        final CollectionReference colRef =
            collectionReference.document('bar').collection('baz');
        expect(colRef.parent().documentID, equals('bar'));
      });
    });

    group('Query', () {
      test('getDocuments', () async {
        QuerySnapshot snapshot =
            await collectionReference.getDocuments(source: Source.server);
        DocumentSnapshot document = snapshot.documents.first;
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));

        // startAtDocument
        snapshot =
            await collectionReference.startAtDocument(document).getDocuments();
        document = snapshot.documents.first;
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));

        // startAfterDocument
        snapshot = await collectionReference
            .startAfterDocument(document)
            .getDocuments();
        document = snapshot.documents.first;
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));

        // endAtDocument
        snapshot =
            await collectionReference.endAtDocument(document).getDocuments();
        document = snapshot.documents.first;
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));

        // endBeforeDocument
        snapshot = await collectionReference
            .endBeforeDocument(document)
            .getDocuments();
        document = snapshot.documents.first;
        expect(document.documentID, equals('0'));
        expect(document.reference.path, equals('foo/0'));
        expect(document.data, equals(kMockDocumentSnapshotData));

        expect(
          log,
          equals(
            <Matcher>[
              isMethodCall(
                'Query#getDocuments',
                arguments: <String, dynamic>{
                  'app': app.name,
                  'path': 'foo',
                  'source': 'server',
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[],
                  },
                },
              ),
              isMethodCall(
                'Query#getDocuments',
                arguments: <String, dynamic>{
                  'app': app.name,
                  'path': 'foo',
                  'source': 'default',
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[],
                    'startAtDocument': <String, dynamic>{
                      'id': '0',
                      'data': kMockDocumentSnapshotData,
                    },
                  },
                },
              ),
              isMethodCall(
                'Query#getDocuments',
                arguments: <String, dynamic>{
                  'app': app.name,
                  'path': 'foo',
                  'source': 'default',
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[],
                    'startAfterDocument': <String, dynamic>{
                      'id': '0',
                      'data': kMockDocumentSnapshotData,
                    },
                  },
                },
              ),
              isMethodCall(
                'Query#getDocuments',
                arguments: <String, dynamic>{
                  'app': app.name,
                  'path': 'foo',
                  'source': 'default',
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[],
                    'endAtDocument': <String, dynamic>{
                      'id': '0',
                      'data': kMockDocumentSnapshotData,
                    },
                  },
                },
              ),
              isMethodCall(
                'Query#getDocuments',
                arguments: <String, dynamic>{
                  'app': app.name,
                  'path': 'foo',
                  'source': 'default',
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[],
                    'endBeforeDocument': <String, dynamic>{
                      'id': '0',
                      'data': kMockDocumentSnapshotData,
                    },
                  },
                },
              ),
            ],
          ),
        );
      });
    });

    group('FirestoreMessageCodec', () {
      const MessageCodec<dynamic> codec = FirestoreMessageCodec();
      final DateTime testTime = new DateTime(2015, 10, 30, 11, 16);
      test('should encode and decode simple messages', () {
        _checkEncodeDecode<dynamic>(codec, testTime);
        _checkEncodeDecode<dynamic>(
            codec, const GeoPoint(37.421939, -122.083509));
        _checkEncodeDecode<dynamic>(codec, firestore.document('foo/bar'));
      });
      test('should encode and decode composite message', () {
        final List<dynamic> message = <dynamic>[
          testTime,
          const GeoPoint(37.421939, -122.083509),
          firestore.document('foo/bar'),
        ];
        _checkEncodeDecode<dynamic>(codec, message);
      });
      test('encode and decode blob', () {
        final Uint8List bytes = new Uint8List(4);
        bytes[0] = 128;
        final Blob message = new Blob(bytes);
        _checkEncodeDecode<dynamic>(codec, message);
      });
<<<<<<< HEAD
=======

      test('encode and decode FieldValue', () {
        _checkEncodeDecode<dynamic>(codec, FieldValue.arrayUnion(<int>[123]));
        _checkEncodeDecode<dynamic>(codec, FieldValue.arrayRemove(<int>[123]));
        _checkEncodeDecode<dynamic>(codec, FieldValue.delete());
        _checkEncodeDecode<dynamic>(codec, FieldValue.serverTimestamp());
        _checkEncodeDecode<dynamic>(codec, FieldValue.increment(1.0));
        _checkEncodeDecode<dynamic>(codec, FieldValue.increment(1));
      });
    });

    group('Timestamp', () {
      test('is accurate for dates after epoch', () {
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(22501);
        final Timestamp timestamp = Timestamp.fromDate(date);

        expect(timestamp.seconds, equals(22));
        expect(timestamp.nanoseconds, equals(501000000));
      });

      test('is accurate for dates before epoch', () {
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(-1250);
        final Timestamp timestamp = Timestamp.fromDate(date);

        expect(timestamp.seconds, equals(-2));
        expect(timestamp.nanoseconds, equals(750000000));
      });

      test('creates equivalent timestamps regardless of factory', () {
        const int kMilliseconds = 22501;
        const int kMicroseconds = 22501000;
        final DateTime date =
            DateTime.fromMicrosecondsSinceEpoch(kMicroseconds);

        final Timestamp timestamp = Timestamp(22, 501000000);
        final Timestamp milliTimestamp =
            Timestamp.fromMillisecondsSinceEpoch(kMilliseconds);
        final Timestamp microTimestamp =
            Timestamp.fromMicrosecondsSinceEpoch(kMicroseconds);
        final Timestamp dateTimestamp = Timestamp.fromDate(date);

        expect(timestamp, equals(milliTimestamp));
        expect(milliTimestamp, equals(microTimestamp));
        expect(microTimestamp, equals(dateTimestamp));
      });

      test('correctly compares timestamps', () {
        final Timestamp alpha = Timestamp.fromDate(DateTime(2017, 5, 11));
        final Timestamp beta1 = Timestamp.fromDate(DateTime(2018, 2, 19));
        final Timestamp beta2 = Timestamp.fromDate(DateTime(2018, 4, 2));
        final Timestamp beta3 = Timestamp.fromDate(DateTime(2018, 4, 20));
        final Timestamp preview = Timestamp.fromDate(DateTime(2018, 6, 20));
        final List<Timestamp> inOrder = <Timestamp>[
          alpha,
          beta1,
          beta2,
          beta3,
          preview
        ];

        final List<Timestamp> timestamps = <Timestamp>[
          beta2,
          beta3,
          alpha,
          preview,
          beta1
        ];
        timestamps.sort();
        expect(_deepEqualsList(timestamps, inOrder), isTrue);
      });

      test('rejects dates outside RFC 3339 range', () {
        final List<DateTime> invalidDates = <DateTime>[
          DateTime.fromMillisecondsSinceEpoch(-70000000000000),
          DateTime.fromMillisecondsSinceEpoch(300000000000000),
        ];

        invalidDates.forEach((DateTime date) {
          expect(() => Timestamp.fromDate(date), throwsArgumentError);
        });
      });
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
    });

    group('WriteBatch', () {
      test('set', () async {
        final WriteBatch batch = firestore.batch();
        batch.setData(
          collectionReference.document('bar'),
          <String, String>{'bazKey': 'quxValue'},
        );
        await batch.commit();
        expect(
          log,
          <Matcher>[
            isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
              'app': app.name,
            }),
            isMethodCall(
              'WriteBatch#setData',
              arguments: <String, dynamic>{
                'app': app.name,
                'handle': 1,
                'path': 'foo/bar',
                'data': <String, String>{'bazKey': 'quxValue'},
                'options': <String, bool>{'merge': false},
              },
            ),
            isMethodCall(
              'WriteBatch#commit',
              arguments: <String, dynamic>{
                'handle': 1,
              },
            ),
          ],
        );
      });
      test('merge set', () async {
        final WriteBatch batch = firestore.batch();
        batch.setData(
          collectionReference.document('bar'),
          <String, String>{'bazKey': 'quxValue'},
          merge: true,
        );
        await batch.commit();
        expect(
          log,
          <Matcher>[
            isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
              'app': app.name,
            }),
            isMethodCall('WriteBatch#setData', arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': 'foo/bar',
              'data': <String, String>{'bazKey': 'quxValue'},
              'options': <String, bool>{'merge': true},
            }),
            isMethodCall(
              'WriteBatch#commit',
              arguments: <String, dynamic>{
                'handle': 1,
              },
            ),
          ],
        );
      });
      test('update', () async {
        final WriteBatch batch = firestore.batch();
        batch.updateData(
          collectionReference.document('bar'),
          <String, String>{'bazKey': 'quxValue'},
        );
        await batch.commit();
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'WriteBatch#create',
              arguments: <String, dynamic>{
                'app': app.name,
              },
            ),
            isMethodCall(
              'WriteBatch#updateData',
              arguments: <String, dynamic>{
                'app': app.name,
                'handle': 1,
                'path': 'foo/bar',
                'data': <String, String>{'bazKey': 'quxValue'},
              },
            ),
            isMethodCall(
              'WriteBatch#commit',
              arguments: <String, dynamic>{
                'handle': 1,
              },
            ),
          ],
        );
      });
      test('delete', () async {
        final WriteBatch batch = firestore.batch();
        batch.delete(collectionReference.document('bar'));
        await batch.commit();
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'WriteBatch#create',
              arguments: <String, dynamic>{
                'app': app.name,
              },
            ),
            isMethodCall(
              'WriteBatch#delete',
              arguments: <String, dynamic>{
                'app': app.name,
                'handle': 1,
                'path': 'foo/bar',
              },
            ),
            isMethodCall(
              'WriteBatch#commit',
              arguments: <String, dynamic>{
                'handle': 1,
              },
            ),
          ],
        );
      });
    });
  });
}

void _checkEncodeDecode<T>(MessageCodec<T> codec, T message) {
  final ByteData encoded = codec.encodeMessage(message);
  final T decoded = codec.decodeMessage(encoded);
  if (message == null) {
    expect(encoded, isNull);
    expect(decoded, isNull);
  } else {
    expect(_deepEquals(message, decoded), isTrue);
    final ByteData encodedAgain = codec.encodeMessage(decoded);
    expect(
      encodedAgain.buffer.asUint8List(),
      orderedEquals(encoded.buffer.asUint8List()),
    );
  }
}

bool _deepEquals(dynamic valueA, dynamic valueB) {
  if (valueA is TypedData)
    return valueB is TypedData && _deepEqualsTypedData(valueA, valueB);
  if (valueA is List) return valueB is List && _deepEqualsList(valueA, valueB);
  if (valueA is Map) return valueB is Map && _deepEqualsMap(valueA, valueB);
  if (valueA is double && valueA.isNaN) return valueB is double && valueB.isNaN;
  return valueA == valueB;
}

bool _deepEqualsTypedData(TypedData valueA, TypedData valueB) {
  if (valueA is ByteData) {
    return valueB is ByteData &&
        _deepEqualsList(
            valueA.buffer.asUint8List(), valueB.buffer.asUint8List());
  }
  if (valueA is Uint8List)
    return valueB is Uint8List && _deepEqualsList(valueA, valueB);
  if (valueA is Int32List)
    return valueB is Int32List && _deepEqualsList(valueA, valueB);
  if (valueA is Int64List)
    return valueB is Int64List && _deepEqualsList(valueA, valueB);
  if (valueA is Float64List)
    return valueB is Float64List && _deepEqualsList(valueA, valueB);
  throw 'Unexpected typed data: $valueA';
}

bool _deepEqualsList(List<dynamic> valueA, List<dynamic> valueB) {
  if (valueA.length != valueB.length) return false;
  for (int i = 0; i < valueA.length; i++) {
    if (!_deepEquals(valueA[i], valueB[i])) return false;
  }
  return true;
}

bool _deepEqualsMap(
    Map<dynamic, dynamic> valueA, Map<dynamic, dynamic> valueB) {
  if (valueA.length != valueB.length) return false;
  for (final dynamic key in valueA.keys) {
    if (!valueB.containsKey(key) || !_deepEquals(valueA[key], valueB[key]))
      return false;
  }
  return true;
}
<<<<<<< HEAD
=======

bool _deepEqualsFieldValue(FieldValue valueA, FieldValue valueB) {
  if (valueA.type != valueB.type) return false;
  if (valueA.value == null) return valueB.value == null;
  if (valueA.value is List) return _deepEqualsList(valueA.value, valueB.value);
  if (valueA.value is Map) return _deepEqualsMap(valueA.value, valueB.value);
  return valueA.value == valueB.value;
}
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
