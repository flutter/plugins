// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

void main() {
  runApp(const MyApp());
}

/// App for testing
class MyApp extends StatelessWidget {
  /// Default Constructor
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(
          body: _List(),
        ),
      );
}

class _List extends StatelessWidget {
  const _List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: 5000,
        itemBuilder: (_, int index) => Link(
          uri: Uri.parse('https://example.com/$index'),
          builder: (_, __) => Text('#$index', textAlign: TextAlign.center),
        ),
      );
}
