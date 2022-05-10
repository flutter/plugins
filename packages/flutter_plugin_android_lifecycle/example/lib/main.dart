// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sample flutter_plugin_android_lifecycle usage'),
        ),
        body: const Center(
            child: Text(
                'This plugin only provides Android Lifecycle API\n for other Android plugins.')),
      ),
    );
  }
}
