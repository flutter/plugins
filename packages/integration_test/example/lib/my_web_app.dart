import 'dart:html' as html;
import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

void startApp() => runApp(MyWebApp());

class MyWebApp extends StatefulWidget {
  @override
  _MyWebAppState createState() => _MyWebAppState();
}

class _MyWebAppState extends State<MyWebApp> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                'Platform: ${html.window.navigator.platform}\n',
                key: Key('platform'),
              ),
              Text(
                '$_counter',
                key: Key('counter'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      padding: const EdgeInsets.all(10.0),
                      onPressed: _increment,
                      key: Key('button'),
                      child:
                          const Text('Button!', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
