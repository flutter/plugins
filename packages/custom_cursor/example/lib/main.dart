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
            child: kIsWeb
                ? Wrap(
                    children: [
                      'all-scroll',
                      'auto',
                      'cell',
                      'context-menu',
                      'col-resize',
                      'copy',
                      'crosshair',
                      'default',
                      'e-resize',
                      'ew-resize',
                      'grab',
                      'grabbing',
                      'help',
                      'move',
                      'n-resize',
                      'ne-resize',
                      'nesw-resize',
                      'ns-resize',
                      'nw-resize',
                      'nwse-resize',
                      'no-drop',
                      'none',
                      'not-allowed',
                      'pointer',
                      'progress',
                      'row-resize',
                      's-resize',
                      'se-resize',
                      'sw-resize',
                      'text',
                      'w-resize',
                      'wait',
                      'zoom-in',
                      'zoom-out',
                    ].map((t) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MouseRegion(
                          onEnter: (_) =>
                              CustomCursorPlugin().setWebCursor(WebCursor(t)),
                          onExit: (_) => CustomCursorPlugin().resetCursor(),
                          child: Text(t),
                        ),
                      );
                    }).toList(),
                  )
                : Wrap(
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
                  ),
          ),
        ),
      ),
    );
  }
}
