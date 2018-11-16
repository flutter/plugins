// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

enum _ImageType { file, bytes }

/// Indicates the image rotation.
///
/// Rotation is counter-clockwise and is only used to rotate Android images.
enum ImageRotation { rotation_0, rotation_90, rotation_180, rotation_270 }

/// This enum specifies where the origin (0,0) of the image is located.
///
/// Only used to change orientation of iOS images.
enum ImageOrientation {
  /// Orientation code indicating the 0th row is the top and the 0th column is the left side.
  topLeft,

  /// Orientation code indicating the 0th row is the top and the 0th column is the right side.
  topRight,

  /// Orientation code indicating the 0th row is the bottom and the 0th column is the left side.
  bottomLeft,

  /// Orientation code indicating the 0th row is the bottom and the 0th column is the right side.
  bottomRight,

  /// Orientation code indicating the 0th row is the left side and the 0th column is the top.
  leftTop,

  /// Orientation code indicating the 0th row is the left side and the 0th column is the bottom.
  leftBottom,

  /// Orientation code indicating the 0th row is the right side and the 0th column is the top.
  rightTop,

  /// Orientation code indicating the 0th row is the right side and the 0th column is the bottom.
  rightBottom,
}

/// The Firebase machine learning vision API.
///
/// You can get an instance by calling [FirebaseVision.instance] and then get
/// a detector from the instance:
///
/// ```dart
/// TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
/// ```
class FirebaseVision {
  FirebaseVision._();

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_ml_vision');

  /// Singleton of [FirebaseVision].
  ///
  /// Use this get an instance of a detector:
  ///
  /// ```dart
  /// TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  /// ```
  static final FirebaseVision instance = FirebaseVision._();

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

  /// Creates an instance of [TextRecognizer].
  TextRecognizer textRecognizer() => TextRecognizer._();

  /// Creates an instance of [CloudLabelDetector].
  CloudLabelDetector cloudLabelDetector([CloudDetectorOptions options]) {
    return CloudLabelDetector._(options ?? const CloudDetectorOptions());
  }
}

/// Represents an image object used for both on-device and cloud API detectors.
///
/// Create an instance by calling one of the factory constructors.
class FirebaseVisionImage {
  const FirebaseVisionImage._({
    @required _ImageType type,
    FirebaseVisionImageMetadata metadata,
    File imageFile,
    Uint8List bytes,
  })  : _imageFile = imageFile,
        _metadata = metadata,
        _bytes = bytes,
        _type = type;

  /// Construct a [FirebaseVisionImage] from a file.
  factory FirebaseVisionImage.fromFile(File imageFile) {
    assert(imageFile != null);
    return FirebaseVisionImage._(
      type: _ImageType.file,
      imageFile: imageFile,
    );
  }

  /// Construct a [FirebaseVisionImage] from a file path.
  factory FirebaseVisionImage.fromFilePath(String imagePath) {
    assert(imagePath != null);
    return FirebaseVisionImage._(
      type: _ImageType.file,
      imageFile: File(imagePath),
    );
  }

  /// Construct a [FirebaseVisionImage] from a list of bytes.
  factory FirebaseVisionImage.fromBytes(
    Uint8List bytes,
    FirebaseVisionImageMetadata metadata,
  ) {
    assert(bytes != null);
    return FirebaseVisionImage._(
      type: _ImageType.bytes,
      bytes: bytes,
      metadata: metadata,
    );
  }

  final Uint8List _bytes;
  final File _imageFile;
  final FirebaseVisionImageMetadata _metadata;
  final _ImageType _type;

  Map<String, dynamic> _serialize() => <String, dynamic>{
        'type': _enumToString(_type),
        'bytes': _bytes,
        'path': _imageFile?.path,
        'metadata': _type == _ImageType.bytes ? _metadata._serialize() : null,
      };
}

/// Image metadata used by [FirebaseVision] detectors.
class FirebaseVisionImageMetadata {
  const FirebaseVisionImageMetadata({
    @required this.size,
    this.androidRotation = ImageRotation.rotation_0,
    this.iosOrientation = ImageOrientation.topLeft,
  }) : assert(size != null);

  final Size size;
  final ImageRotation androidRotation;
  final ImageOrientation iosOrientation;

  Map<String, dynamic> _serialize() => <String, dynamic>{
        'width': size.width,
        'height': size.height,
        'rotation': androidRotation.index * 90,
        'orientation': _enumToString(iosOrientation),
      };
}

/// Abstract class for detectors in [FirebaseVision] API.
abstract class FirebaseVisionDetector {
  /// Uses machine learning model to detect objects of interest in an image.
  Future<dynamic> detectInImage(FirebaseVisionImage visionImage);
}

String _enumToString(dynamic enumValue) {
  final String enumString = enumValue.toString();
  return enumString.substring(enumString.indexOf('.') + 1);
}
