part of firebase_mllanguage;

class FirebaseLanguage {
  FirebaseLanguage._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel('firebase_mlkit_language');

  /// Singleton of [FirebaseLanguage].
  ///
  /// Use this get an instance of a Language Identifier/Translator:
  ///
  /// ```dart
  /// LanguageIdentifier languageIdentifier = FirebaseLanguage.instance.languageIdentifier();
  /// ```
  static final FirebaseLanguage instance = FirebaseLanguage._();

  /// Creates an instance of [LanguageIdentifier].
  LanguageIdentifier languageIdentifier([LanguageIdentifierOptions options]) {
    return LanguageIdentifier._(options ?? const LanguageIdentifierOptions());
  }

  /// Creates an instance of [LanguageTranslator].
  LanguageTranslator languageTranslator(
      String fromLanguage, String toLanguage) {
    return LanguageTranslator._(
        toLanguage: toLanguage, fromLanguage: fromLanguage);
  }

  /// Creates an instance of [ModelManager].
  ModelManager modelManager() {
    return ModelManager._();
  }
}
