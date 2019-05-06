import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$Firestore', () {
    Firestore firestore;

    setUp(() async {
      final FirebaseApp app = await FirebaseApp.configure(
        name: 'test',
        options: const FirebaseOptions(
          googleAppID: '1:79601577497:ios:5f2bcc6ba8cecddd',
          gcmSenderID: '79601577497',
          apiKey: 'AIzaSyArgmRGfB5kiQT6CunAOmKRVKEsxKmy6YI-G72PVU',
          projectID: 'flutter-firestore',
        ),
      );
      firestore = Firestore(app: app);
    });

    test('getDocuments', () async {
      final Query query = firestore
          .collection('messages')
          .where('message', isEqualTo: 'Hello world!')
          .limit(1);
      final QuerySnapshot querySnapshot = await query.getDocuments();
      expect(querySnapshot.documents.first['message'], 'Hello world!');
      final DocumentReference firstDoc =
          querySnapshot.documents.first.reference;
      final DocumentSnapshot documentSnapshot = await firstDoc.get();
      expect(documentSnapshot.data['message'], 'Hello world!');
      final DocumentSnapshot snapshot = await firstDoc.snapshots().first;
      expect(snapshot.data['message'], 'Hello world!');
    });

    test('increment', () async {
      final DocumentReference ref = firestore.collection('messages').document();
      await ref.setData(<String, dynamic>{
        'message': 1,
        'created_at': FieldValue.serverTimestamp(),
      });
      DocumentSnapshot snapshot = await ref.get();
      expect(snapshot.data['message'], 1);
      await ref.updateData(<String, dynamic>{
        'message': FieldValue.increment(1),
      });
      snapshot = await ref.get();
      expect(snapshot.data['message'], 2);
      await ref.updateData(<String, dynamic>{
        'message': FieldValue.increment(40.1),
      });
      snapshot = await ref.get();
      expect(snapshot.data['message'], 42.1);
      await ref.delete();
    });

    test('runTransaction', () async {
      final DocumentReference ref = firestore.collection('messages').document();
      await ref.setData(<String, dynamic>{
        'message': 'testing',
        'created_at': FieldValue.serverTimestamp(),
      });
      final DocumentSnapshot initialSnapshot = await ref.get();
      expect(initialSnapshot.data['message'], 'testing');
      final dynamic result = await firestore.runTransaction(
        (Transaction tx) async {
          final DocumentSnapshot snapshot = await tx.get(ref);
          final Map<String, dynamic> updatedData =
              Map<String, dynamic>.from(snapshot.data);
          updatedData['message'] = 'testing2';
          await tx.update(ref, updatedData);
          return updatedData;
        },
      );
      expect(result['message'], 'testing2');
      await ref.delete();
      final DocumentSnapshot nonexistentSnapshot = await ref.get();
      expect(nonexistentSnapshot.data, null);
      expect(nonexistentSnapshot.exists, false);
    });

    test('pagination', () async {
      // Populate the database with two test documents
      final CollectionReference messages = firestore.collection('messages');
      final DocumentReference doc1 = messages.document();
      // Use document ID as a unique identifier to ensure that we don't
      // collide with other tests running against this database.
      final String testRun = doc1.documentID;
      await doc1.setData(<String, dynamic>{
        'message': 'pagination testing1',
        'test_run': testRun,
        'created_at': FieldValue.serverTimestamp(),
      });
      final DocumentSnapshot snapshot1 = await doc1.get();
      final DocumentReference doc2 = messages.document();
      await doc2.setData(<String, dynamic>{
        'message': 'pagination testing2',
        'test_run': testRun,
        'created_at': FieldValue.serverTimestamp(),
      });
      final DocumentSnapshot snapshot2 = await doc2.get();

      QuerySnapshot snapshot;
      List<DocumentSnapshot> results;

      // startAtDocument
      snapshot = await messages
          .where('test_run', isEqualTo: testRun)
          .startAtDocument(snapshot1)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 2);
      expect(results[0].data['message'], 'pagination testing1');
      expect(results[1].data['message'], 'pagination testing2');

      // startAfterDocument
      snapshot = await messages
          .where('test_run', isEqualTo: testRun)
          .startAfterDocument(snapshot1)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 1);
      expect(results[0].data['message'], 'pagination testing2');

      // endAtDocument
      snapshot = await messages
          .where('test_run', isEqualTo: testRun)
          .endAtDocument(snapshot2)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 2);
      expect(results[0].data['message'], 'pagination testing1');
      expect(results[1].data['message'], 'pagination testing2');

      // endBeforeDocument
      snapshot = await messages
          .where('test_run', isEqualTo: testRun)
          .endBeforeDocument(snapshot2)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 1);
      expect(results[0].data['message'], 'pagination testing1');

      // Clean up
      await doc1.delete();
      await doc2.delete();
    });
  });
}
