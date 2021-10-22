// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Home Page of the application
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      primary: Colors.blue,
      onPrimary: Colors.white,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Selector Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: style,
              child: const Text('Open a text file'),
              onPressed: () => Navigator.pushNamed(context, '/open/text'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: style,
              child: const Text('Open an image'),
              onPressed: () => Navigator.pushNamed(context, '/open/image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: style,
              child: const Text('Open multiple images'),
              onPressed: () => Navigator.pushNamed(context, '/open/images'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: style,
              child: const Text('Save a file'),
              onPressed: () => Navigator.pushNamed(context, '/save/text'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: style,
              child: const Text('Open a get directory dialog'),
              onPressed: () => Navigator.pushNamed(context, '/directory'),
            ),
          ],
        ),
      ),
    );
  }
}
