import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreList', () {
    int mockHandleId = 0;
    StreamController<QuerySnapshot> streamController;
    final List<MethodCall> log = <MethodCall>[];
    FirestoreList list;
    FirebaseApp app;
    Firestore firestore;
    CollectionReference collectionReference;
    const Map<String, dynamic> kMockDocumentSnapshotData = <String, dynamic>{
      '1': 2
    };

    setUp(() async {
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

      firestore = Firestore(app: app);
      collectionReference = firestore.collection('foo');

      streamController = StreamController<QuerySnapshot>();

      list = FirestoreList(
        query: streamController.stream,
        debug: false,
      );

      Firestore.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            final int handle = mockHandleId++;
            // Wait before sending a message back.
            // Otherwise the first request didn't have the time to finish.
            new Future<void>.delayed(Duration.zero).then<void>((_) {
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
            new Future<void>.delayed(Duration.zero).then<void>((_) {
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

    Future<void> processChange(QuerySnapshot querySnapshot) async {
      streamController.add(querySnapshot);
    }

    test('can add to empty list', () async {
      expect(collectionReference.id, "foo");
      await processChange(await collectionReference.snapshots().first);
      expect(list.length, 1);
      expect(list[0].data, kMockDocumentSnapshotData);
    });
  });
}
