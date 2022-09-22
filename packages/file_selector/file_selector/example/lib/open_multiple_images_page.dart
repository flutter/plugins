// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen that shows an example of openFiles
class OpenMultipleImagesPage extends StatelessWidget {
  /// Default Constructor
  const OpenMultipleImagesPage({Key? key}) : super(key: key);

  Future<void> _openImageFile(BuildContext context) async {
    // #docregion MultiOpen
    // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
    // ignore: prefer_const_constructors
    final XTypeGroup jpgsTypeGroup = XTypeGroup(
      label: 'JPEGs',
      extensions: <String>['jpg', 'jpeg'],
    );
    // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
    // ignore: prefer_const_constructors
    final XTypeGroup pngTypeGroup = XTypeGroup(
      label: 'PNGs',
      extensions: <String>['png'],
    );
    final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
      jpgsTypeGroup,
      pngTypeGroup,
    ]);
    // #enddocregion MultiOpen
    if (files.isEmpty) {
      // Operation was canceled by the user.
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => MultipleImagesDisplay(files),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open multiple images'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
                // ignore: deprecated_member_use
                primary: Colors.blue,
                // ignore: deprecated_member_use
                onPrimary: Colors.white,
              ),
              child: const Text('Press to open multiple images (png, jpg)'),
              onPressed: () => _openImageFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog
class MultipleImagesDisplay extends StatelessWidget {
  /// Default Constructor
  const MultipleImagesDisplay(this.files, {Key? key}) : super(key: key);

  /// The files containing the images
  final List<XFile> files;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gallery'),
      // On web the filePath is a blob url
      // while on other platforms it is a system path.
      content: Center(
        child: Row(
          children: <Widget>[
            ...files.map(
              (XFile file) => Flexible(
                  child: kIsWeb
                      ? Image.network(file.path)
                      : Image.file(File(file.path))),
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
