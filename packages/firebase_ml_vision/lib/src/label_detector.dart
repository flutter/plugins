// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Used for finding [ImageLabel]s in a supplied image.
///
/// When you use the API, you get a list of the entities that were recognized:
/// people, things, places, activities, and so on. Each label found comes with a
/// score that indicates the confidence the ML model has in its relevance. With
/// this information, you can perform tasks such as automatic metadata
/// generation and content moderation.
///
/// A image labeler is created via
/// `imageLabeler([ImageLabelerOptions options])` or
/// `cloudImageLabeler([CloudImageLabelerOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final ImageLabeler imageLabeler =
///     FirebaseVision.instance.imageLabeler(options);
///
/// final List<ImageLabel> labels = await imageLabeler.processImage(image);
/// ```
class ImageLabeler {
  ImageLabeler._({@required dynamic options, @required this.modelType})
      : _options = options,
        assert(_options != null),
        assert(modelType != null);

  /// Indicates whether this labeler is ran on device or in the cloud.
  final ModelType modelType;

  // Should be of type ImageLabelerOptions or CloudImageLabelerOptions.
  final dynamic _options;

  /// Finds entities in the input image.
  Future<List<ImageLabel>> processImage(FirebaseVisionImage visionImage) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'ImageLabeler#processImage',
      <String, dynamic>{
        'options': <String, dynamic>{
          'modelType': _enumToString(modelType),
          'confidenceThreshold': _options.confidenceThreshold,
        },
      }..addAll(visionImage._serialize()),
    );

    final List<ImageLabel> labels = <ImageLabel>[];
    for (dynamic data in reply) {
      labels.add(ImageLabel._(data));
    }

    return labels;
  }
}

/// Options for on device image labeler.
///
/// Confidence threshold could be provided for the label detection. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class ImageLabelerOptions {
  /// Constructor for [ImageLabelerOptions].
  ///
  /// Confidence threshold could be provided for the label detection.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const ImageLabelerOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Options for cloud image labeler.
///
/// Confidence threshold could be provided for the label detection. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class CloudImageLabelerOptions {
  /// Constructor for [CloudImageLabelerOptions].
  ///
  /// Confidence threshold could be provided for the label detection.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const CloudImageLabelerOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Represents an entity label detected by [ImageLabeler] and [CloudImageLabeler].
class ImageLabel {
  ImageLabel._(dynamic data)
      : confidence = data['confidence'],
        entityId = data['entityId'],
        text = data['text'];

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
  final String text;
}
