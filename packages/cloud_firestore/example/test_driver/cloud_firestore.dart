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
      final CollectionReference reference = firestore.collection('messages');
      final QuerySnapshot snapshot = await reference.getDocuments();
      expect(snapshot.documents.length, isNonZero);
    });
  });
}
