import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/src/ui/firestore_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:test/test.dart';

void main() {
  group('FirestoreList', () {
    int mockHandleId = 0;
    StreamController<QuerySnapshot> streamController;
    final List<MethodCall> log = <MethodCall>[];
    FirestoreList list;
    Completer<ListChange> callbackCompleter;
    FirebaseApp app;
    Firestore firestore;
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

      callbackCompleter = Completer<ListChange>();
      streamController = StreamController<QuerySnapshot>();

      void completeWithChange(int index, DocumentSnapshot snapshot) {
        callbackCompleter.complete(ListChange.at(index, snapshot));
      }

      list = FirestoreList(
        query: streamController.stream,
        onDocumentAdded: completeWithChange,
        onDocumentChanged: completeWithChange,
        onDocumentRemoved: completeWithChange,
        debug: true,
      );

      Firestore.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            final int handle = mockHandleId++;
            // Wait before sending a message back.
            // Otherwise the first request didn't have the time to finish.
            await Future<void>.delayed(Duration.zero).then((_) {
              BinaryMessages.handlePlatformMessage(
                Firestore.channel.name,
                Firestore.channel.codec.encodeMethodCall(
                  MethodCall('QuerySnapshot', <String, dynamic>{
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
            Future<void>.delayed(Duration.zero).then((_) {
              BinaryMessages.handlePlatformMessage(
                Firestore.channel.name,
                Firestore.channel.codec.encodeMethodCall(
                  MethodCall('DocumentSnapshot', <String, dynamic>{
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
            } else if (methodCall.arguments['path'] == 'foo/add') {
              return <String, dynamic>{
                'path': 'foo/add',
                'data': kMockDocumentSnapshotData
              };
            } else if (methodCall.arguments['path'] == 'foo/notExists') {
              return <String, dynamic>{'path': 'foo/notExists', 'data': null};
            }
            throw PlatformException(code: 'UNKNOWN_PATH');
          case 'Firestore#runTransaction':
            return <String, dynamic>{'1': 3};
          case 'Transaction#get':
            if (methodCall.arguments['path'] == 'foo/bar') {
              return <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, dynamic>{'key1': 'val1'}
              };
            } else if (methodCall.arguments['path'] == 'foo/add') {
              return <String, dynamic>{
                'path': 'foo/add',
                'data': kMockDocumentSnapshotData
              };
            } else if (methodCall.arguments['path'] == 'foo/notExists') {
              return <String, dynamic>{'path': 'foo/notExists', 'data': null};
            }
            throw PlatformException(code: 'UNKNOWN_PATH');
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

    Future<ListChange> resetCompleterOnCallback() async {
      final ListChange result = await callbackCompleter.future;
      callbackCompleter = Completer<ListChange>();
      return result;
    }

    Future<ListChange> processChange(QuerySnapshot querySnapshot) {
      streamController.add(querySnapshot);
      return resetCompleterOnCallback();
    }

    firestore
        .collection("foo")
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      processChange(querySnapshot);
    });

    test('can add to empty list', () async {
      final DocumentSnapshot snapshot =
          await firestore.document("foo/add").get();
      expect(
        await processChange(await firestore.collection("foo").getDocuments()),
        ListChange.at(0, snapshot),
      );
      expect(list, <DocumentSnapshot>[snapshot]);
    });
  });
}

class ListChange {
  ListChange.at(int index, DocumentSnapshot snapshot)
      : this._(index, null, snapshot);

  ListChange.move(int from, int to, DocumentSnapshot snapshot)
      : this._(from, to, snapshot);

  ListChange._(this.index, this.index2, this.snapshot);

  final int index;
  final int index2;
  final DocumentSnapshot snapshot;

  @override
  String toString() => '$runtimeType[$index, $index2, $snapshot]';

  @override
  bool operator ==(Object o) {
    return o is ListChange &&
        index == o.index &&
        index2 == o.index2 &&
        snapshot == o.snapshot;
  }

  @override
  int get hashCode => index;
}
