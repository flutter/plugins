import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            try {
              dynamic resp = await CloudFunctions.instance.call(functionName: 'iaw');
              final String str = resp['message'];
              print(str);
            } on CloudFunctionsException catch (e) {
              print('caught firebase functions exception');
              print(e.code);
              print(e.message);
              print(e.details);
            } catch (e) {
              print('caught generic exception');
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
