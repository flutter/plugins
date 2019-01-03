// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Detector for detecting and labeling entities in an input image.
///
/// When you use the API, you get a list of the entities that were recognized:
/// people, things, places, activities, and so on. Each label found comes with a
/// score that indicates the confidence the ML model has in its relevance. With
/// this information, you can perform tasks such as automatic metadata
/// generation and content moderation.
///
/// A label detector is created via labelDetector(LabelDetectorOptions options)
/// in [FirebaseVision]:
///
/// ```dart
/// LabelDetector labelDetector = FirebaseVision.instance.labelDetector(options);
/// ```
class LabelDetector extends FirebaseVisionDetector {
  LabelDetector._(this.options) : assert(options != null);

  /// The options for the detector.
  ///
  /// Sets the confidence threshold for detecting entities.
  final LabelDetectorOptions options;

  /// Detects entities in the input image.
  ///
  /// Performed asynchronously.
  @override
  Future<List<Label>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'LabelDetector#detectInImage',
      <String, dynamic>{
        'options': <String, dynamic>{
          'confidenceThreshold': options.confidenceThreshold,
        },
      }..addAll(visionImage._serialize()),
    );

    final List<Label> labels = <Label>[];
    for (dynamic data in reply) {
      labels.add(Label._(data));
    }

    return labels;
  }
}

/// Detector for detecting and labeling entities in an input image.
///
/// Uses cloud machine learning models and will require enabling Cloud API.
///
/// When you use the API, you get a list of the entities that were recognized:
/// people, things, places, activities, and so on. Each label found comes with a
/// score that indicates the confidence the ML model has in its relevance. With
/// this information, you can perform tasks such as automatic metadata
/// generation and content moderation.
///
/// A cloud label detector is created via cloudLabelDetector(CloudDetectorOptions options)
/// in [FirebaseVision]:
///
/// ```dart
/// CloudLabelDetector cloudLabelDetector = FirebaseVision.instance.cloudLabelDetector(options);
/// ```
class CloudLabelDetector extends FirebaseVisionDetector {
  CloudLabelDetector._(this.options) : assert(options != null);

  /// Options used to configure this cloud detector.
  final CloudDetectorOptions options;

  /// Detects entities in the input image.
  ///
  /// Performed asynchronously.
  @override
  Future<List<Label>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'CloudLabelDetector#detectInImage',
      <String, dynamic>{
        'options': options._serialize(),
      }..addAll(visionImage._serialize()),
    );

    final List<Label> labels = <Label>[];
    for (dynamic data in reply) {
      labels.add(Label._(data));
    }

    return labels;
  }
}

/// Options for Label detector.
///
/// Confidence threshold could be provided for the label detection. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class LabelDetectorOptions {
  /// Constructor for [LabelDetectorOptions].
  ///
  /// Confidence threshold could be provided for the label detection.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const LabelDetectorOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Represents an entity label detected by [LabelDetector].
class Label {
  Label._(dynamic data)
      : confidence = data['confidence'],
        entityId = data['entityId'],
        label = data['label'];

  /// The overall confidence of the result. Range [0.0, 1.0].
  final double confidence;

  /// The opaque entity ID.
  ///
  /// IDs are available in Google Knowledge Graph Search API
  /// https://developers.google.com/knowledge-graph/
  final String entityId;

  /// A detected label from the given image.
  ///
  /// The label returned here is in English only. The end developer should use
  /// [entityId] to retrieve unique id.
  final String label;
}
