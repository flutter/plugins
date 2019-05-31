// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
<<<<<<< HEAD
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
=======
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'repeat')
          ..timeout = const Duration(seconds: 30);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
                      final HttpsCallableResult result = await callable.call(
                        <String, dynamic>{
                          'message': 'hello world!',
                          'count': _responseCount,
                        },
                      );
                      print(result.data);
                      setState(() {
                        _response = result.data['repeat_message'];
                        _responseCount = result.data['repeat_count'];
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
