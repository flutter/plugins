import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseStorage', () {
    const String kTestString = 'hello world';
    FirebaseStorage firebaseStorage;

    setUp(() async {
      firebaseStorage = FirebaseStorage();
    });

    test('putFile, getDownloadURL, writeToFile', () async {
      final String uuid = Uuid().v1();
      final Directory systemTempDir = Directory.systemTemp;
      final File file =
          await File('${systemTempDir.path}/foo$uuid.txt').create();
      await file.writeAsString(kTestString);
      final StorageReference ref =
          firebaseStorage.ref().child('text').child('foo$uuid.txt');
      expect(await ref.getName(), 'foo$uuid.txt');
      expect(await ref.getPath(), 'text/foo$uuid.txt');
      final StorageUploadTask uploadTask = ref.putFile(
        file,
        StorageMetadata(
          contentLanguage: 'en',
          customMetadata: <String, String>{'activity': 'test'},
        ),
      );
      final StorageTaskSnapshot complete = await uploadTask.onComplete;
      expect(complete.storageMetadata.sizeBytes, kTestString.length);
      expect(complete.storageMetadata.contentLanguage, 'en');
      expect(complete.storageMetadata.customMetadata['activity'], 'test');

      final String url = await ref.getDownloadURL();
      final http.Response downloadData = await http.get(url);
      expect(downloadData.body, kTestString);
      expect(downloadData.headers['content-type'], 'text/plain');
      final File tempFile = File('${systemTempDir.path}/tmp$uuid.txt');
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
      await tempFile.create();
      expect(await tempFile.readAsString(), '');
      final StorageFileDownloadTask task = ref.writeToFile(tempFile);
      final int byteCount = (await task.future).totalByteCount;
      final String tempFileContents = await tempFile.readAsString();
      expect(tempFileContents, kTestString);
      expect(byteCount, kTestString.length);
    });
  });
}
