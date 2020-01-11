# custom_cursor_example

Demonstrates how to use the custom_cursor plugin.

## Example

```dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:custom_cursor/custom_cursor.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            width: 400,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (kIsWeb) {
      return _buildWebBody();
    }
    if (Platform.isMacOS) {
      return _buildMacOSBody();
    }
    return Wrap(
      children: CursorType.values.map((t) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MouseRegion(
            onEnter: (_) => CustomCursorPlugin().setCursor(t),
            onExit: (_) => CustomCursorPlugin().resetCursor(),
            child: Text(describeEnum(t)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWebBody() {
    return Wrap(
      children: WebCursor.values.map((t) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MouseRegion(
            onEnter: (_) =>
                CustomCursorPlugin().setWebCursor(WebCursor.custom(t)),
            onExit: (_) => CustomCursorPlugin().resetCursor(),
            child: Text(t),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMacOSBody() {
    return Wrap(
      children: MacOSCursor.values.map((t) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MouseRegion(
            onEnter: (_) =>
                CustomCursorPlugin().setMacOSCursor(MacOSCursor.custom(t)),
            onExit: (_) => CustomCursorPlugin().resetCursor(),
            child: Text(t),
          ),
        );
      }).toList(),
    );
  }
}

```