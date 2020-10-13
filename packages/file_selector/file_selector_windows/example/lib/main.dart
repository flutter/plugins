// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'File Selector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<dynamic> _selectorResult;

  Widget _showResult(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      String text;
      if (!snapshot.hasData) {
        return Text('');
      } else if (snapshot.data is String) {
        text = snapshot.data;
      } else if (snapshot.data is XFile) {
        text = (snapshot.data as XFile).path;
      } else if (snapshot.data is List<XFile>) {
        text = (snapshot.data as List<XFile>).map((e) => e.path).join(', ');
      } else {
        text = 'Unexpected return type: ${snapshot.data}';
      }
      return Text(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('SAVE'),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectorResult =
                            FileSelectorPlatform.instance.getSavePath(
                          suggestedName: 'a_file.txt',
                          initialDirectory: r'C:\Users',
                          confirmButtonText: 'Save It',
                        );
                      });
                    },
                  ),
                  RaisedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('OPEN MULTIPLE'),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectorResult =
                            FileSelectorPlatform.instance.openFiles(
                          initialDirectory: r'C:\',
                          confirmButtonText: 'Open All',
                          /*acceptedTypeGroups: <XTypeGroup>[
                          XTypeGroup(label: 'Any'),
                          XTypeGroup(
                            label: 'Text',
                            extensions: <String>[
                              'txt',
                              'rtf',
                            ],
                          ),
                        ],*/
                        );
                      });
                    },
                  ),
                  RaisedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('OPEN SINGLE MEDIA'),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectorResult =
                            FileSelectorPlatform.instance.openFile(
                          acceptedTypeGroups: <XTypeGroup>[
                            XTypeGroup(
                              label: 'Images',
                              extensions: <String>[
                                'bmp',
                                'gif',
                                'jpeg',
                                'jpg',
                                'png',
                                'tiff',
                                'webp',
                              ],
                            ),
                            XTypeGroup(
                              label: 'Video',
                              extensions: <String>[
                                'webm'
                                'mpg',
                                'mpeg',
                                'mov',
                              ],
                            ),
                          ],
                        );
                      });
                    },
                  ),
                  RaisedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('OPEN DIRECTORY'),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectorResult =
                            FileSelectorPlatform.instance.getDirectoryPath(
                          initialDirectory: r'C:\Users',
                          confirmButtonText: 'Open Directory',
                        );
                      });
                    },
                  ),
                ],
              ),
              FutureBuilder<void>(
                  future: _selectorResult, builder: _showResult),
            ],
          ),
        ],
      ),
    );
  }
}
