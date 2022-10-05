// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select an image file using
/// `openFiles`, then displays the selected images in a gallery dialog.
class OpenImagePage extends StatelessWidget {
  /// Default Constructor
  const OpenImagePage({Key? key}) : super(key: key);

  Future<void> _openImageFile(BuildContext context) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
    );
    final XFile? file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
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

/// Widget that displays an image in a dialog.
class ImageDisplay extends StatelessWidget {
  /// Default Constructor.
  const ImageDisplay(this.fileName, this.filePath, {Key? key})
      : super(key: key);

  /// The name of the selected file.
  final String fileName;

  /// The path to the selected file.
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
