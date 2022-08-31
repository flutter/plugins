// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Home Page of the application.
class HomePage extends StatelessWidget {
  /// Default Constructor
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
      // ignore: deprecated_member_use
      primary: Colors.blue,
      // ignore: deprecated_member_use
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
          ],
        ),
      ),
    );
  }
}
