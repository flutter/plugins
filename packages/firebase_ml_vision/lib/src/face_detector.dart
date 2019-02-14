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
/// A face detector is created via
/// `faceDetector([FaceDetectorOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
///
/// final List<Faces> faces = await faceDetector.processImage(image);
/// ```
class FaceDetector {
  FaceDetector._(this.options) : assert(options != null);

  /// The options for the face detector.
  final FaceDetectorOptions options;

  /// Detects faces in the input image.
  Future<List<Face>> processImage(FirebaseVisionImage visionImage) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'FaceDetector#processImage',
      <String, dynamic>{
        'options': <String, dynamic>{
          'enableClassification': options.enableClassification,
          'enableLandmarks': options.enableLandmarks,
          'enableTracking': options.enableTracking,
          'minFaceSize': options.minFaceSize,
          'mode': _enumToString(options.mode),
        },
      }..addAll(visionImage._serialize()),
    );

    final List<Face> faces = <Face>[];
    for (dynamic data in reply) {
      faces.add(Face._(data));
    }

    return faces;
  }
}

/// Immutable options for configuring features of [FaceDetector].
///
/// Used to configure features such as classification, face tracking, speed,
/// etc.
class FaceDetectorOptions {
  /// Constructor for [FaceDetectorOptions].
  ///
  /// The parameter minFaceValue must be between 0.0 and 1.0, inclusive.
  const FaceDetectorOptions({
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
  ///
  /// Must be a value between 0.0 and 1.0.
  final double minFaceSize;

  /// Option for controlling additional accuracy / speed trade-offs.
  final FaceDetectorMode mode;
}

/// Represents a face detected by [FaceDetector].
class Face {
  Face._(dynamic data)
      : boundingBox = Rect.fromLTWH(
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
        _landmarks = Map<FaceLandmarkType, FaceLandmark>.fromIterables(
            FaceLandmarkType.values,
            FaceLandmarkType.values.map((FaceLandmarkType type) {
          final List<dynamic> pos = data['landmarks'][_enumToString(type)];
          return (pos == null)
              ? null
              : FaceLandmark._(
                  type,
                  Offset(pos[0], pos[1]),
                );
        }));

  final Map<FaceLandmarkType, FaceLandmark> _landmarks;

  /// The axis-aligned bounding rectangle of the detected face.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Rect boundingBox;

  /// The rotation of the face about the vertical axis of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler Y angle is turned to the camera's right and
  /// to its left.
  ///
  /// The Euler Y angle is guaranteed only when using the "accurate" mode
  /// setting of the face detector (as opposed to the "fast" mode setting, which
  /// takes some shortcuts to make detection faster).
  final double headEulerAngleY;

  /// The rotation of the face about the axis pointing out of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler Z angle is rotated counter-clockwise relative
  /// to the camera.
  ///
  /// ML Kit always reports the Euler Z angle of a detected face.
  final double headEulerAngleZ;

  /// Probability that the face's left eye is open.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double leftEyeOpenProbability;

  /// Probability that the face's right eye is open.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double rightEyeOpenProbability;

  /// Probability that the face is smiling.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double smilingProbability;

  /// The tracking ID if the tracking is enabled.
  ///
  /// Null if tracking was not enabled.
  final int trackingId;

  /// Gets the landmark based on the provided [FaceLandmarkType].
  ///
  /// Null if landmark was not detected.
  FaceLandmark getLandmark(FaceLandmarkType landmark) => _landmarks[landmark];
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
  final Offset position;
}
