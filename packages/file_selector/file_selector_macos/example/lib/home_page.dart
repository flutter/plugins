import 'package:flutter/material.dart';

/// Home Page of the application
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Selector Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Open a text file'),
              onPressed: () => Navigator.pushNamed(context, '/open/text'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Open an image'),
              onPressed: () => Navigator.pushNamed(context, '/open/image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Open multiple images'),
              onPressed: () => Navigator.pushNamed(context, '/open/images'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Save a file'),
              onPressed: () => Navigator.pushNamed(context, '/save/text'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Open a get directory dialog'),
              onPressed: () => Navigator.pushNamed(context, '/directory'),
            ),
          ],
        ),
      ),
    );
  }
}
