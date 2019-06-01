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
  }

  final TextEditingController inputTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    inputTextController.dispose();
    super.dispose();
  }

  String translatedText = "Translated Text";
  String inputText;
  String identifiedLang = "Detected Language";

  void onPressed() async {
    inputText = inputTextController.text;
    final String result = await FirebaseLanguage.instance
        .languageTranslator(
            SupportedLanguages.English, SupportedLanguages.Spanish)
        .processText(inputText);
    setState(() {
      translatedText = result;
    });
  }

  void onPoked() async {
    inputText = inputTextController.text;
    final List<LanguageLabel> result = await FirebaseLanguage.instance
        .languageIdentifier()
        .processText(inputText);

    setState(() {
      identifiedLang = result[0].languageCode; //returns most probable
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Plug-In Example App"),
            backgroundColor: Colors.blue,
          ),
          body: Container(
            padding: const EdgeInsets.all(50),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(controller: inputTextController),
                  const SizedBox(height: 50),
                  RaisedButton(
                      child: Text("Translate",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blue,
                      onPressed: onPressed),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(child: Text(translatedText), height: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RaisedButton(
                      child: Text("Identify Language",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blue,
                      onPressed: onPoked),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(identifiedLang),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
