import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that shows an example of openFiles
class OpenMultipleImagesPage extends StatelessWidget {
  void _openImageFile(BuildContext context) async {
    final jpgsTypeGroup = XTypeGroup(
      label: 'JPEGs',
      extensions: ['jpg', 'jpeg'],
    );
    final pngTypeGroup = XTypeGroup(
      label: 'PNGs',
      extensions: ['png'],
    );
    final files =
        await FileSelectorPlatform.instance.openFiles(acceptedTypeGroups: [
      jpgsTypeGroup,
      pngTypeGroup,
    ]);
    await showDialog(
      context: context,
      builder: (context) => MultipleImagesDisplay(files),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open multiple images'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
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
  const MultipleImagesDisplay(this.files);

  /// The files containing the images
  final List<XFile> files;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gallery'),
      // On web the filePath is a blob url
      // while on other platforms it is a system path.
      content: Center(
        child: Row(
          children: <Widget>[
            ...files.map(
              (file) => Flexible(
                  child: kIsWeb
                      ? Image.network(file.path)
                      : Image.file(File(file.path))),
            )
          ],
        ),
      ),
      actions: [
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
