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

    test('runTransaction', () async {
      final DocumentReference ref = firestore.collection('messages').document();
      await ref.updateData(<String, dynamic>{
        'message': 'testing',
        'created_at': FieldValue.serverTimestamp(),
      });
      final Map<String, dynamic> result =
          await Firestore.instance.runTransaction(
        (Transaction tx) async {
          final DocumentSnapshot snapshot = await tx.get(ref);
          expect(snapshot['message'], 'testing');
          await tx.update(ref, <String, dynamic>{'message': 'testing2'});
        },
      );
      assert(result['message'], 'testing2');
      final DocumentSnapshot updatedSnapshot = await ref.get();
      assert(updatedSnapshot['message'], 'testing2');
      await ref.delete();
      final DocumentSnapshot nonexistentSnapshot = await ref.get();
      assert(nonexistentSnapshot.exists, false);
    });
  });
}
