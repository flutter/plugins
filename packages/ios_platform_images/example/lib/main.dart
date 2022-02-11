// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:ios_platform_images/ios_platform_images.dart';

void main() => runApp(const MyApp());

/// Main widget for the example app.
class MyApp extends StatefulWidget {
  /// Default Constructor
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    IosPlatformImages.resolveURL('textfile')
        // ignore: avoid_print
        .then((String? value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color iconColor = theme.iconTheme.color ?? theme.colorScheme.secondary;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          // 'flutter' is a resource in Assets.xcassets, 'face.smiling' is an SFSymbol provided with iOS.
          child: Column(
            children: [
              Text('This is an icon from the iOS bundle'),
              Image(
                image: IosPlatformImages.load('flutter'),
                semanticLabel: 'Flutter logo',
              ),
              Text('This is an icon from the iOS system'),
              Image(
                image: IosPlatformImages.loadSystemImage(
                    'face.smiling', [iconColor], 100, 1, 1),
                semanticLabel: 'Smiling face',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
