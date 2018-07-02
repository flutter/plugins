// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Option for controlling additional trade-offs in performing face detection.
///
/// Accurate tends to detect more faces and may be more precise in determining
/// values such as position, at the cost of speed.
enum FaceDetectorMode { accurate, fast }

/// Available face landmarks detected by [FaceDetector].
enum FaceLandmarkType {
  bottomMouth,
  leftCheek,
  leftEar,
  leftEye,
  leftMouth,
  noseBase,
  rightCheek,
  rightEar,
  rightEye,
  rightMouth,
}

/// Detector for detecting faces in an input image.
///
/// A face detector is created via `faceDetector(FaceDetectorOptions options)`
/// in [FirebaseVision]:
///
/// ```dart
/// FaceDetector faceDetector = FirebaseVision.instance.faceDetector(options);
/// ```
class FaceDetector extends FirebaseVisionDetector {
  FaceDetector._(this.options) : _handle = _nextHandle++;

  static int _nextHandle = 0;

  final int _handle;

  /// The options for the face detector.
  final FaceDetectorOptions options;

  /// Closes the face detector and release its model resources.
  @override
  Future<void> close() async {
    return FirebaseVision.channel.invokeMethod('FaceDetector#close');
  }

  /// Detects faces in the input image.
  @override
  Future<List<Face>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'FaceDetector#detectInImage',
      <String, dynamic>{
        'path': visionImage.imageFile.path,
        'handle': _handle,
        'enableClassification': options.enableClassification,
        'enableLandmarks': options.enableLandmarks,
        'enableTracking': options.enableTracking,
        'minFaceSize': options.minFaceSize,
        'mode': options.mode == FaceDetectorMode.fast ? 'fast' : 'accurate',
      },
    );

    final List<Face> faces = <Face>[];
    reply.forEach((dynamic data) {
      faces.add(new Face._(data));
    });

    return faces;
  }
}

/// Options for [FaceDetector].
class FaceDetectorOptions {
  FaceDetectorOptions({
    this.enableClassification = false,
    this.enableLandmarks = false,
    this.enableTracking = false,
    this.minFaceSize = 0.1,
    this.mode = FaceDetectorMode.fast,
  })  : assert(minFaceSize >= 0.0),
        assert(minFaceSize <= 1.0);

  /// Whether to run additional classifiers for characterizing attributes.
  ///
  /// E.g. "smiling" and "eyes open".
  final bool enableClassification;

  /// Whether to detect [FaceLandmark]s.
  final bool enableLandmarks;

  /// Whether to enable face tracking.
  ///
  /// If enabled, the detector will maintain a consistent ID for each face when
  /// processing consecutive frames.
  final bool enableTracking;

  /// The smallest desired face size.
  ///
  /// Expressed as a proportion of the width of the head to the image width.
  final double minFaceSize;

  /// Option for controlling additional accuracy / speed trade-offs.
  final FaceDetectorMode mode;
}

/// Represents a face detected by [FaceDetector].
class Face {
  Face._(dynamic data)
      : boundingBox = Rectangle<int>(
          data['left'],
          data['top'],
          data['width'],
          data['height'],
        ),
        headEulerAngleY = data['headEulerAngleY'],
        headEulerAngleZ = data['headEulerAngleZ'],
        leftEyeOpenProbability = data['leftEyeOpenProbability'],
        rightEyeOpenProbability = data['rightEyeOpenProbability'],
        smilingProbability = data['smilingProbability'],
        trackingId = data['trackingId'],
        _landmarks = _getLandmarks(data['landmarks']);

  final Map<FaceLandmarkType, FaceLandmark> _landmarks;

  /// The axis-aligned bounding rectangle of the detected face.
  final Rectangle<int> boundingBox;

  /// The rotation of the face about the vertical axis of the image.
  final double headEulerAngleY;

  /// The rotation of the face about the axis pointing out of the image.
  final double headEulerAngleZ;

  /// Probability that the face's left eye is open.
  ///
  /// Returns a value between 0.0 and 1.0. Returns `null` if probability was not
  /// computed.
  final double leftEyeOpenProbability;

  /// Probability that the face's right eye is open.
  ///
  /// Returns a value between 0.0 and 1.0. Returns `null` if probability was not
  /// computed.
  final double rightEyeOpenProbability;

  /// Probability that the face is smiling.
  ///
  /// Returns a value between 0.0 and 1.0. Returns `null` if probability was not
  /// computed.
  final double smilingProbability;

  /// The tracking ID if the tracking is enabled.
  ///
  /// Returns `null` if tracking was not enabled.
  final int trackingId;

  /// Gets the landmark based on the provided [FaceLandmarkType].
  ///
  /// Returns null if landmark was not detected.
  FaceLandmark landmark(FaceLandmarkType landmark) => _landmarks[landmark];
}

/// Represent a face landmark.
///
/// A landmark is a point on a detected face, such as an eye, nose, or mouth.
class FaceLandmark {
  FaceLandmark._(this.type, this.position);

  /// The [FaceLandmarkType] of this landmark.
  final FaceLandmarkType type;

  /// Gets a 2D point for landmark position.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Point<int> position;
}

Map<FaceLandmarkType, FaceLandmark> _getLandmarks(dynamic data) {
  final Map<FaceLandmarkType, FaceLandmark> landmarks =
      <FaceLandmarkType, FaceLandmark>{};

  data.forEach((dynamic key, dynamic point) {
    FaceLandmarkType landmarkType;
    switch (key) {
      case 'bottomMouth':
        landmarkType = FaceLandmarkType.bottomMouth;
        break;
      case 'leftCheek':
        landmarkType = FaceLandmarkType.leftCheek;
        break;
      case 'leftEar':
        landmarkType = FaceLandmarkType.leftEar;
        break;
      case 'leftEye':
        landmarkType = FaceLandmarkType.leftEye;
        break;
      case 'leftMouth':
        landmarkType = FaceLandmarkType.leftMouth;
        break;
      case 'noseBase':
        landmarkType = FaceLandmarkType.noseBase;
        break;
      case 'rightCheek':
        landmarkType = FaceLandmarkType.rightCheek;
        break;
      case 'rightEar':
        landmarkType = FaceLandmarkType.rightEar;
        break;
      case 'rightEye':
        landmarkType = FaceLandmarkType.rightEye;
        break;
      case 'rightMouth':
        landmarkType = FaceLandmarkType.rightMouth;
        break;
      default:
        throw new ArgumentError.value(
            key, 'Landmark name', 'Not valid landmark.');
    }

    landmarks[landmarkType] = FaceLandmark._(
      landmarkType,
      Point<int>(point[0], point[1]),
    );
  });

  return landmarks;
}
