// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen that shows an example of openFiles
class OpenImagePage extends StatelessWidget {
  /// Default Constructor
  const OpenImagePage({Key? key}) : super(key: key);

  Future<void> _openImageFile(BuildContext context) async {
    // #docregion SingleOpen
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    // #enddocregion SingleOpen
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }
    final String fileName = file.name;
    final String filePath = file.path;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => ImageDisplay(fileName, filePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open an image'),
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
              child: const Text('Press to open an image file(png, jpg)'),
              onPressed: () => _openImageFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog
class ImageDisplay extends StatelessWidget {
  /// Default Constructor
  const ImageDisplay(this.fileName, this.filePath, {Key? key})
      : super(key: key);

  /// Image's name
  final String fileName;

  /// Image's path
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(fileName),
      // On web the filePath is a blob url
      // while on other platforms it is a system path.
      content: kIsWeb ? Image.network(filePath) : Image.file(File(filePath)),
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
