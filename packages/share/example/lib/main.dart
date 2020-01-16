// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatefulWidget {
  @override
  DemoAppState createState() => DemoAppState();
}

class DemoAppState extends State<DemoApp> {
  String text = '';
  String subject = '';
  bool shareFile = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Plugin Demo',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Share Plugin Demo'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Share text:',
                    hintText: 'Enter some text and/or link to share',
                  ),
                  maxLines: 2,
                  onChanged: (String value) => setState(() {
                    text = value;
                  }),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Share subject:',
                    hintText: 'Enter subject to share (optional)',
                  ),
                  maxLines: 2,
                  onChanged: (String value) => setState(() {
                    subject = value;
                  }),
                ),
                const Padding(padding: EdgeInsets.only(top: 12.0)),
                InkWell(
                  onTap: () => setState(() {
                    shareFile = !shareFile;
                  }),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: shareFile,
                        onChanged: (bool value) => setState(() {
                          shareFile = value;
                        }),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Share file",
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          Text(
                            "Text file with share text as content",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 12.0)),
                Builder(
                  builder: (BuildContext context) {
                    return RaisedButton(
                      child: const Text('Share'),
                      onPressed: text.isEmpty
                          ? null
                          : () async {
                              // A builder is used to retrieve the context immediately
                              // surrounding the RaisedButton.
                              //
                              // The context's `findRenderObject` returns the first
                              // RenderObject in its descendent tree when it's not
                              // a RenderObjectWidget. The RaisedButton's RenderObject
                              // has its position and size after it's built.
                              final RenderBox box = context.findRenderObject();

                              if (shareFile) {
                                // Could use image_picker here
                                // - after migration of it to v2
                                //  - https://github.com/flutter/flutter/issues/41839
                                //  - https://github.com/flutter/plugins/pull/2430
                                final File file =
                                    await _createTextFile('sample.txt', text);
                                await Share.shareFile(file,
                                    subject: subject,
                                    sharePositionOrigin:
                                        box.localToGlobal(Offset.zero) &
                                            box.size);
                              } else {
                                await Share.share(text,
                                    subject: subject,
                                    sharePositionOrigin:
                                        box.localToGlobal(Offset.zero) &
                                            box.size);
                              }
                            },
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }

  Future<File> _createTextFile(String filename, String content) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file;
  }
}
