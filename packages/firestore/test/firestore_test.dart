// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_firestore/firestore.dart';

void main() {
  group('$Firestore', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/firebase_firestore',
    );

    int mockHandleId = 0;
    final Firestore firestore = Firestore.instance;
    final List<MethodCall> log = <MethodCall>[];
    final CollectionReference collectionReference = firestore.collection('foo');

    setUp(() async {
      mockHandleId = 0;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch(methodCall.method) {
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
        QuerySnapshot snapshot;
        final int handleId = mockHandleId;
        final StreamSubscription<QuerySnapshot> subscription =
        collectionReference.snapshots.listen((QuerySnapshot querySnapshot) {
          snapshot = querySnapshot;
        });
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          equals(<MethodCall>[
            new MethodCall(
              'Query#addSnapshotListener',
              <String, dynamic> {
                'path': 'foo',
                'parameters': <String, dynamic>{}
              },
            ),
          ]),
        );
        final Map<String, dynamic> document = <String, dynamic>{ 'baz': 'quox' };
        final Map<String, dynamic> documentChange = <String, dynamic>{
          'type': 'DocumentChange.added',
          'document': document,
          'oldIndex': -1,
          'newIndex': -1,
        };
        await BinaryMessages.handlePlatformMessage(
            Firestore.channel.name,
            Firestore.channel.codec.encodeMethodCall(
              new MethodCall('QuerySnapshot',
                <String, dynamic>{
                  'id': handleId,
                  'documents': <Map>[ document ],
                  'documentChanges': <Map>[ documentChange ],
                }),
              ),
            (_) {},
        );
        expect(snapshot.documents.length, equals(1));
        expect(snapshot.documentChanges.length, equals(1));
        expect(snapshot.documents[0].data, equals(document));
        expect(snapshot.documentChanges[0].type.toString(), equals(documentChange['type']));
        expect(snapshot.documentChanges[0].document.data, equals(documentChange['document']));
        expect(snapshot.documentChanges[0].oldIndex, equals(documentChange['oldIndex']));
        expect(snapshot.documentChanges[0].newIndex, equals(documentChange['newIndex']));
        log.clear();
        subscription.cancel();
        await new Future<Null>.delayed(Duration.ZERO);
        expect(
          log,
          equals(<MethodCall>[
            new MethodCall(
              'Query#removeListener',
              <String, dynamic> {
                'handle': handleId
              },
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
          equals(<MethodCall>[
            new MethodCall(
              'Query#addDocumentListener',
              <String, dynamic> {
                'path': 'foo',
              },
            ),
            new MethodCall(
              'Query#removeListener',
              <String, dynamic> {
                'handle': 0
              },
            )
          ]),
        );
      });
      test('set', () async {
        await collectionReference.document('bar').setData(<String, String>{'bazKey': 'quxValue'});
        expect(
          log,
          equals(<MethodCall>[
            new MethodCall(
              'DocumentReference#setData',
              <String, dynamic> {
                'path': 'foo/bar',
                'data': {
                  'bazKey': 'quxValue'
                }
              },
            ),
          ]),
        );
      });
    });
  });
}
