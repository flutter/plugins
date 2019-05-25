import 'package:flutter/material.dart';

import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    check();
  }

  void check() async {
    final String test = "testing this function";

    FirebaseLanguage.instance
        .languageIdentifier()
        .processText(test)
        .then((List<LanguageLabel> onValue) {
      print(onValue[0].languageCode);
    });

    FirebaseLanguage.instance
        .modelManager()
        .downloadModel(SupportedLanguages.Greek)
        .then((String onValue) {
      print(onValue);
    });

    FirebaseLanguage.instance
        .languageTranslator(
            SupportedLanguages.English, SupportedLanguages.Vietnamese)
        .processText(test)
        .then((String onValue) {
      print(onValue);
    });

    FirebaseLanguage.instance
        .modelManager()
        .deleteModel(SupportedLanguages.Greek)
        .then((String onValue) {
      print(onValue);
    });

    FirebaseLanguage.instance
        .modelManager()
        .viewModels()
        .then((List<String> onValue) {
      print(onValue);
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
