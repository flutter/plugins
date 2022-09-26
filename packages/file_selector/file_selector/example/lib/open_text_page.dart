// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Screen that shows an example of openFile
class OpenTextPage extends StatelessWidget {
  /// Default Constructor
  const OpenTextPage({Key? key}) : super(key: key);

  Future<void> _openTextFile(BuildContext context) async {
    // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
    // ignore: prefer_const_constructors
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'text',
      extensions: <String>['txt', 'json'],
    );
    // This demonstrates using an initial directory for the prompt, which should
    // only be done in cases where the application can likely predict where the
    // file would be. In most cases, this parameter should not be provided.
    final String initialDirectory =
        (await getApplicationDocumentsDirectory()).path;
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
      initialDirectory: initialDirectory,
    );
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }
    final String fileName = file.name;
    final String fileContent = await file.readAsString();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => TextDisplay(fileName, fileContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open a text file'),
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
              child: const Text('Press to open a text file (json, txt)'),
              onPressed: () => _openTextFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog
class TextDisplay extends StatelessWidget {
  /// Default Constructor
  const TextDisplay(this.fileName, this.fileContent, {Key? key})
      : super(key: key);

  /// File's name
  final String fileName;

  /// File to display
  final String fileContent;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(fileName),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Text(fileContent),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
