// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// The Firebase machine learning vision API.
///
/// You can get an instance by calling [FirebaseVision.instance] and then get
/// a detector from the instance:
///
/// ```dart
/// TextDetector textDetector = FirebaseVision.instance.getTextDetector();
/// ```
class FirebaseVision {
  Stream<dynamic> liveViewStream;

  FirebaseVision._() {
    liveViewStream = const EventChannel(
            'plugins.flutter.io/firebase_ml_vision/liveViewEvents')
        .receiveBroadcastStream()
        .where((dynamic event) => event['eventType'] == 'detection')
        .map<LiveViewDetectionResult>((dynamic event) {
          print("mapping!");

          // get the image size
          final Map<dynamic, dynamic> sizeMap = event['imageSize'];
          int width = sizeMap['width'];
          int height = sizeMap['height'];
          final imageSize = Size(width.toDouble(), height.toDouble());

          // get the data
          final List<dynamic> reply = event['data'];
          // get the data type
          final String detectionType = event['detectionType'];
          if (detectionType == "barcode") {
            final List<Barcode> barcodes = <Barcode>[];
            reply.forEach((dynamic barcodeMap) {
              barcodes.add(new Barcode(barcodeMap));
            });
            return new LiveViewBarcodeDetectionResult(barcodes, imageSize);
          } else if (detectionType == "text") {
            final List<TextBlock> texts = <TextBlock>[];
            reply.forEach((dynamic block) {
              texts.add(TextBlock.fromBlockData(block));
            });
            return new LiveViewTextDetectionResult(texts, imageSize);
          } else if (detectionType == "face") {
            final List<Face> faces = <Face>[];
            reply.forEach((dynamic f) {
              faces.add(new Face(f));
            });
            return new LiveViewFaceDetectionResult(faces, imageSize);
          } else if (detectionType == "label") {
            final List<Label> labels = <Label>[];
            reply.forEach((dynamic l) {
              labels.add(new Label(l));
            });
            return new LiveViewLabelDetectionResult(labels, imageSize);
          }
          return new LiveViewDefaultDetectionResult();
    }).asBroadcastStream();
  }

  @visibleForTesting
  static final MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_ml_vision');

  /// Singleton of [FirebaseVision].
  ///
  /// Use this get an instance of a detector:
  ///
  /// ```dart
  /// TextDetector textDetector = FirebaseVision.instance.textDetector();
  /// ```
  static final FirebaseVision instance = new FirebaseVision._();

  /// Creates an instance of [BarcodeDetector].
  BarcodeDetector barcodeDetector([BarcodeDetectorOptions options]) {
    return BarcodeDetector._(options ?? const BarcodeDetectorOptions());
  }

  /// Creates an instance of [FaceDetector].
  FaceDetector faceDetector([FaceDetectorOptions options]) {
    return FaceDetector._(options ?? const FaceDetectorOptions());
  }

  /// Creates an instance of [LabelDetector].
  LabelDetector labelDetector([LabelDetectorOptions options]) {
    return LabelDetector._(options ?? const LabelDetectorOptions());
  }

  /// Creates an instance of [TextDetector].
  TextDetector textDetector() => new TextDetector._();

  Future<Null> setLiveViewDetector(FirebaseVisionDetectorType type,
      [VisionOptions options]) async {
    final String typeMessage = detectorMessageType(type);
    if (typeMessage == null) return;
    await FirebaseVision.channel
        .invokeMethod("LiveView#setDetector", <String, dynamic>{
      "detectorType": typeMessage,
      "options": options?.toMap() ?? <String, dynamic>{},
    });
  }

  String detectorMessageType(FirebaseVisionDetectorType type) {
    switch (type) {
      case FirebaseVisionDetectorType.barcode:
        return "barcode";
      case FirebaseVisionDetectorType.face:
        return "face";
      case FirebaseVisionDetectorType.label:
        return "label";
      case FirebaseVisionDetectorType.text:
        return "text";
      default:
        return null;
    }
  }
}

/// Represents an image object used for both on-device and cloud API detectors.
///
/// Create an instance by calling one of the factory constructors.
class FirebaseVisionImage {
  FirebaseVisionImage._(this.imageFile);

  /// Construct a [FirebaseVisionImage] from a file.
  factory FirebaseVisionImage.fromFile(File imageFile) {
    assert(imageFile != null);
    return FirebaseVisionImage._(imageFile);
  }

  /// Construct a [FirebaseVisionImage] from a file path.
  factory FirebaseVisionImage.fromFilePath(String imagePath) {
    assert(imagePath != null);
    return FirebaseVisionImage._(new File(imagePath));
  }

  /// The file location of the image.
  final File imageFile;
}

/// Abstract class for detectors in [FirebaseVision] API.
abstract class FirebaseVisionDetector {
  /// Uses machine learning model to detect objects of interest in an image.
  Future<dynamic> detectInImage(FirebaseVisionImage visionImage);
}

enum FirebaseVisionDetectorType {
  barcode,
  face,
  label,
  text,
}

String _enumToString(dynamic enumValue) {
  final String enumString = enumValue.toString();
  return enumString.substring(enumString.indexOf('.') + 1);
}
