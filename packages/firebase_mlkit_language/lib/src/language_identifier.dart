part of firebase_mllanguage;

/// Used for finding [LanguageLabel]s in supplied text.
///
///
/// A language identifier is created via
/// `languageIdentifier([LanguageIdentifierOptions options])` in [FirebaseLanguage]:
///
/// ```dart
///
/// final LanguageIdentifier languageIdentifier =
///     FirebaseLanguage.instance.languageIdentifier(options);
///
/// final List<LanguageLabel> labels = await languageIdentifier.processText("Sample Text");
/// ```

class LanguageIdentifier {
  LanguageIdentifier._(LanguageIdentifierOptions options)
      : _options = options,
        assert(options != null);

  // Should be of type LanguageIdentifierOptions.
  final LanguageIdentifierOptions _options;

  /// Finds language labels in the input text.
  Future<List<LanguageLabel>> processText(String text) async {
    final List<dynamic> reply = await FirebaseLanguage.channel
        .invokeMethod('LanguageIdentifier#processText', <String, dynamic>{
      'options': <String, dynamic>{
        'confidenceThreshold': _options.confidenceThreshold,
      },
      'text': text
    });

    final List<LanguageLabel> labels = <LanguageLabel>[];
    for (dynamic data in reply) {
      labels.add(LanguageLabel._(data));
    }

    return labels;
  }
}

/// Options for on device language labeler.
///
/// Confidence threshold could be provided for the language identification. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class LanguageIdentifierOptions {
  /// Constructor for [LanguageIdentifierOptions].
  ///
  /// Confidence threshold could be provided for the language identification.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const LanguageIdentifierOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Represents a language label detected by [LanguageIdentifier].
class LanguageLabel {
  LanguageLabel._(dynamic data)
      : confidence = data['confidence'],
        languageCode = data['languageCode'];

  /// The overall confidence of the result. Range [0.0, 1.0].
  final double confidence;

  /// A detected language from the given text.
  final String languageCode;
}
