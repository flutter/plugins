import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that shows an example of getDirectoryPath
class GetDirectoryPage extends StatelessWidget {
  void _getDirectoryPath(BuildContext context) async {
    const confirmButtonText = 'Choose';
    final directoryPath = await FileSelectorPlatform.instance.getDirectoryPath(
      confirmButtonText: confirmButtonText,
    );
    await showDialog(
      context: context,
      builder: (context) => TextDisplay(directoryPath ?? 'Unknown'),
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
              child: const Text('Press to ask user to choose a directory'),
              onPressed: () => _getDirectoryPath(context),
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
  const TextDisplay(this.directoryPath);

  /// Directory path
  final String directoryPath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selected Directory'),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Text(directoryPath),
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
