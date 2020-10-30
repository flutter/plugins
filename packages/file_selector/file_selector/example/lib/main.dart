import 'package:flutter/material.dart';
import 'package:example/home_page.dart';
import 'package:example/save_text_page.dart';
import 'package:example/open_text_page.dart';
import 'package:example/open_image_page.dart';
import 'package:example/open_multiple_images_page.dart';

void main() {
  runApp(MyApp());
}

/// MyApp is the Main Application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Selector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      routes: {
        '/save/text': (context) => SaveTextPage(),
        '/open/text': (context) => OpenTextPage(),
        '/open/image': (context) => OpenImagePage(),
        '/open/images': (context) => OpenMultipleImagesPage(),
      },
    );
  }
}
