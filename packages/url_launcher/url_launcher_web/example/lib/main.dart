// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

void main() {
  runApp(MyApp());
}

class _HorizontalScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
      };
}

/// App for testing
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: const _List(),
          ),
        ),
      );
}

class _List extends StatelessWidget {
  const _List({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
        behavior: _HorizontalScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 500,
          separatorBuilder: (_, __) => const SizedBox(height: 24, width: 24),
          itemBuilder: (_, int index) => Link(
            uri: Uri.parse('https://example.com/$index'),
            builder: (_, __) => GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('https://example.com/$index')));
              },
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(64),
                child: Text('#$index', textAlign: TextAlign.center),
              )),
            ),
          ),
        ),
      );
}
