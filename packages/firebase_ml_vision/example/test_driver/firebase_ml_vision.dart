// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'barcode_detector.dart';
part 'face_detector.dart';
part 'image_labeler.dart';
part 'text_recognizer.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseVision', () {
    barcodeDetectorTests();
    faceDetectorTests();
    imageLabelerTests();
    textRecognizerTests();
  });
}

int nextHandle = 0;

// Since there is no way to get the full asset filename, this method loads the
// image into a temporary file.
Future<String> _loadImage(String assetFilename) async {
  final Directory directory = await getTemporaryDirectory();

  final String tmpFilename = path.join(
    directory.path,
    "tmp${nextHandle++}.jpg",
  );

  final ByteData data = await rootBundle.load(assetFilename);
  final Uint8List bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );

  await File(tmpFilename).writeAsBytes(bytes);

  return tmpFilename;
}
