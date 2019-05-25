part of firebase_mllanguage;

/// Used for finding [TranslatedTextLabel]s in supplied text.
///
///
/// A language translator is created via
/// `languageTranslator(fromLanguage: SupportedLanguages.lang, toLanguage: SupportedLanguages.lang)` in [FirebaseLanguage]:
///
/// ```dart
///
/// final LanguageTranslator languageTranslator =
///     FirebaseLanguage.instance.languageTranslator(fromLanguage: SupportedLanguages.lang, toLanguage: SupportedLanguages.lang);
///
/// final List<TranslatedTextLabel> labels = await languageTranslator.processText("Sample Text");
/// ```

class LanguageTranslator {
  LanguageTranslator._(
      {@required String fromLanguage, @required String toLanguage})
      : _fromLanguage = fromLanguage,
        _toLanguage = toLanguage,
        assert(fromLanguage != null),
        assert(toLanguage != null);

  final String _fromLanguage;
  final String _toLanguage;

  /// Translates the input text.
  Future<String> processText(String text) async {
    final String reply = await FirebaseLanguage.channel
        .invokeMethod('LanguageTranslator#processText', <String, dynamic>{
      'options': <String, dynamic>{
        'fromLanguage': _fromLanguage,
        'toLanguage': _toLanguage
      },
      'text': text
    });

    return reply;
  }
}

/// Conversion for [SupportedLanguages] to BCP-47 language codes
class SupportedLanguages {
  static const String Afrikaans = 'af';
  static const String Arabic = 'ar';
  static const String Belarusian = 'be';
  static const String Bulgarian = 'bg';
  static const String Bengali = 'bn';
  static const String Catalan = 'ca';
  static const String Czech = 'cs';
  static const String Welsh = 'cy';
  static const String Danish = 'da';
  static const String German = 'de';
  static const String Greek = 'el';
  static const String English = 'en';
  static const String Esperanto = 'eo';
  static const String Spanish = 'es';
  static const String Estonian = 'et';
  static const String Persian = 'fa';
  static const String Finnish = 'fi';
  static const String French = 'fr';
  static const String Irish = 'ga';
  static const String Galician = 'gl';
  static const String Gujarati = 'gu';
  static const String Hebrew = 'he';
  static const String Hindi = 'hi';
  static const String Croatian = 'hr';
  static const String Haitian = 'ht';
  static const String Hungarian = 'hu';
  static const String Indonesian = 'id';
  static const String Icelandic = 'is';
  static const String Italian = 'it';
  static const String Japanese = 'ja';
  static const String Georgian = 'ka';
  static const String Kannada = 'kn';
  static const String Korean = 'ko';
  static const String Lithuanian = 'lt';
  static const String Latvian = 'lv';
  static const String Macedonian = 'mk';
  static const String Marathi = 'mr';
  static const String Malay = 'ms';
  static const String Maltese = 'mt';
  static const String Dutch = 'nl';
  static const String Norwegian = 'no';
  static const String Polish = 'pl';
  static const String Portuguese = 'pt';
  static const String Romanian = 'ro';
  static const String Russian = 'ru';
  static const String Slovak = 'sk';
  static const String Slovenian = 'sl';
  static const String Albanian = 'sq';
  static const String Swedish = 'sv';
  static const String Swahili = 'sw';
  static const String Tamil = 'ta';
  static const String Telugu = 'te';
  static const String Thai = 'th';
  static const String Tagalog = 'tl';
  static const String Turkish = 'tr';
  static const String Ukranian = 'uk';
  static const String Urdu = 'ur';
  static const String Vietnamese = 'vi';
  static const String Chinese = 'zh';
}
