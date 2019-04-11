import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('firebase_ml_vision test driver', () {
    final FirebaseVision vision = FirebaseVision.instance;

    test('$FaceDetector', () async {
      final FaceDetector detector = vision.faceDetector();

      final Directory d = await getApplicationDocumentsDirectory();

      final Directory directory = Directory(d.path + '/flutter_assets');

      List<FileSystemEntity> es = directory.listSync();
      es.forEach((f) => print(f.path));

      final String imagePath =
          path.join(directory.absolute.path, 'flutter_assets/2-faces.jpg');

      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(imagePath);

      final List<Face> faces = await detector.processImage(visionImage);

      expect(faces.length, 2);
    });
  });
}
