// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select a directory using `getDirectoryPath`,
/// then displays the selected directory in a dialog.
class GetDirectoryPage extends StatelessWidget {
  /// Default Constructor
  const GetDirectoryPage({Key? key}) : super(key: key);

  Future<void> _getDirectoryPath(BuildContext context) async {
    const String confirmButtonText = 'Choose';
    final String? directoryPath =
        await FileSelectorPlatform.instance.getDirectoryPath(
      confirmButtonText: confirmButtonText,
    );
    if (directoryPath == null) {
      // Operation was canceled by the user.
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => TextDisplay(directoryPath),
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
              child: const Text('Press to ask user to choose a directory'),
              onPressed: () => _getDirectoryPath(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog.
class TextDisplay extends StatelessWidget {
  /// Creates a `TextDisplay`.
  const TextDisplay(this.directoryPath, {Key? key}) : super(key: key);

  /// The path selected in the dialog.
  final String directoryPath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selected Directory'),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Text(directoryPath),
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
