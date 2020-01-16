// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File imageFile;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                _buildImagePreview(),
                imageFile == null
                    ? ListTile(
                        leading: Icon(Icons.add),
                        title: Text("Add image"),
                        onTap: () async {
                          final image = await ImagePicker.pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {
                            this.imageFile = image;
                          });
                        },
                      )
                    : Container(),
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

                              if (imageFile != null) {
                                await Share.shareFile(imageFile,
                                    text: text,
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

  Widget _buildImagePreview() {
    if (imageFile == null) {
      return Container();
    }
    return Stack(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: Image.file(imageFile),
        ),
        Positioned(
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  imageFile = null;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
