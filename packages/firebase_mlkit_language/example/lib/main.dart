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

  final inputTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    inputTextController.dispose();
    super.dispose();
  }

  var translatedText = "Translated Text";
  var inputText;
  var identifiedLang = "Detected Language";

  void onPressed() async {
    inputText = inputTextController.text;
    var result = await FirebaseLanguage.instance
        .languageTranslator(
            SupportedLanguages.English, SupportedLanguages.Spanish)
        .processText(inputText);
    setState(() {
      translatedText = result;
    });
  }

  void onPoked() async {
    inputText = inputTextController.text;
    var result = await FirebaseLanguage.instance
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
          body: new Container(
            padding: EdgeInsets.all(50),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new TextField(controller: inputTextController),
                  new SizedBox(height: 50),
                  new RaisedButton(
                      child: new Text("Translate",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blue,
                      onPressed: onPressed),
                  new SizedBox(height: 25),
                  new Container(
                    padding: EdgeInsets.all(20),
                    child: new SizedBox(
                        child: new Text(translatedText), height: 20),
                    decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                  new SizedBox(height: 20),
                  new RaisedButton(
                      child: new Text("Identify Language",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.blue,
                      onPressed: onPoked),
                  new SizedBox(height: 25),
                  new Container(
                    padding: EdgeInsets.all(10),
                    child: new Text(identifiedLang),
                    decoration: new BoxDecoration(
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
