// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/get_directory_page.dart';
import 'package:example/home_page.dart';
import 'package:example/open_image_page.dart';
import 'package:example/open_multiple_images_page.dart';
import 'package:example/open_text_page.dart';
import 'package:example/save_text_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// MyApp is the Main Application.
class MyApp extends StatelessWidget {
  /// Default Constructor
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Selector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        '/open/image': (BuildContext context) => const OpenImagePage(),
        '/open/images': (BuildContext context) =>
            const OpenMultipleImagesPage(),
        '/open/text': (BuildContext context) => const OpenTextPage(),
        '/save/text': (BuildContext context) => SaveTextPage(),
        '/directory': (BuildContext context) => const GetDirectoryPage(),
      },
    );
  }
}
