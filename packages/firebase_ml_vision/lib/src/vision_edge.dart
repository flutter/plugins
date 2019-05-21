part of firebase_ml_vision;

/// Used for finding [VisionEdgeImageLabel]s in a supplied image.
///
///
/// A image labeler is created via
/// `visionEdgeImageLabeler(String dataset, [VisionEdgeImageLabelerOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final VisionEdgeImageLabeler imageLabeler =
///     FirebaseVision.instance.visionEdgeImageLabeler("dataset", options);
///
/// final List<VisionEdgeImageLabel> labels = await imageLabeler.processImage(image);
/// ```

class VisionEdgeImageLabeler {
  VisionEdgeImageLabeler._({@required dynamic options, @required String dataset})
      : _options = options,
        _dataset = dataset,
        assert(options != null),
        assert(dataset != null);

  // Should be of type VisionEdgeImageLabelerOptions.
  final dynamic _options;

  final String _dataset;

  /// Finds entities in the input image.
  Future<List<VisionEdgeImageLabel>> processImage(FirebaseVisionImage visionImage) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'VisionEdgeImageLabeler#processImage',
      <String, dynamic>{
        'options': <String, dynamic>{
          'dataset': _dataset,
          'confidenceThreshold': _options.confidenceThreshold,
        },
      }..addAll(visionImage._serialize()),
    );

    final List<VisionEdgeImageLabel> labels = <VisionEdgeImageLabel>[];
    for (dynamic data in reply) {
      labels.add(VisionEdgeImageLabel._(data));
    }

    return labels;
  }
}

/// Options for on device image labeler.
///
/// Confidence threshold could be provided for the label detection. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class VisionEdgeImageLabelerOptions {
  /// Constructor for [VisionEdgeImageLabelerOptions].
  ///
  /// Confidence threshold could be provided for the label detection.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const VisionEdgeImageLabelerOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Represents an entity label detected by [ImageLabeler] and [CloudImageLabeler].
class VisionEdgeImageLabel {
  VisionEdgeImageLabel._(dynamic data)
      : confidence = data['confidence'],
        text = data['text'];

  /// The overall confidence of the result. Range [0.0, 1.0].
  final double confidence;

  /// A detected label from the given image.
  ///
  /// The label returned here is in English only. The end developer should use
  /// [entityId] to retrieve unique id.
  final String text;
}
