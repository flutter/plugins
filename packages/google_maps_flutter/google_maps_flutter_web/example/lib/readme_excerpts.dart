// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('README snippet app'),
        ),
        body: const Text('See example in main.dart'),
      ),
    );
  }

  Future<BitmapDescriptor> getIconFromAssets() async {
    // #docregion CreateFromAsset
    final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
      context,
      size: const Size(48, 48),
    );
    final BitmapDescriptor bitmapDescriptor =
        await BitmapDescriptor.createFromAsset(
            imageConfiguration, 'assets/red_square.png');
    // #enddocregion CreateFromAsset
    return bitmapDescriptor;
  }

  BitmapDescriptor getIconFromBytes() {
    // #docregion CreateFromBytes
    final Uint8List bytes = _getMarkerImageBytes();
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.createFromBytes(bytes, size: const Size(48, 48));
    // #enddocregion CreateFromBytes
    return bitmapDescriptor;
  }

  Uint8List _getMarkerImageBytes() => Uint8List(0);
}
