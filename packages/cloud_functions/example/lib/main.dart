import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _response = 'no response';
  int _responseCount = 0;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Cloud Functions example app'),
        ),
        body: new Center(
          child: new Container(
            margin: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
            child: new Column(
              children: <Widget>[
                new Text('Response $_responseCount: $_response'),
                new MaterialButton(
                  child: const Text('SEND REQUEST'),
                  onPressed: () async {
                    try {
                      final dynamic resp = await CloudFunctions.instance.call(
                          functionName: 'repeat',
                          parameters: <String, dynamic>{
                            'message': 'hello world!',
                            'count': _responseCount,
                          });
                      print(resp);
                      setState(() {
                        _response = resp['repeat_message'];
                        _responseCount = resp['repeat_count'];
                      });
                    } on CloudFunctionsException catch (e) {
                      print('caught firebase functions exception');
                      print(e.code);
                      print(e.message);
                      print(e.details);
                    } catch (e) {
                      print('caught generic exception');
                      print(e);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
