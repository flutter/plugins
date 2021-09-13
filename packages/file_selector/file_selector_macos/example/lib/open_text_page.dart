import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that shows an example of openFile
class OpenTextPage extends StatelessWidget {
  void _openTextFile(BuildContext context) async {
    final typeGroup = XTypeGroup(
      label: 'text',
      extensions: ['txt', 'json'],
    );
    final file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      return;
    }
    final fileName = file.name;
    final fileContent = await file.readAsString();

    await showDialog(
      context: context,
      builder: (context) => TextDisplay(fileName, fileContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open a text file'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
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
  const TextDisplay(this.fileName, this.fileContent);

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
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
