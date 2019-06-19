import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(TestWebviewApp());
}

class TestWebviewApp extends StatelessWidget {
  TestWebviewApp();

  final String encodedWebpage = base64.encode(utf8.encode('''
      <!doctype html>
      <html>
        <head>
          <title>Simple test webpage</title>
        </head>
        <body>
          <h1><a href="#">Simple test webpage</a></h1>
          <p>Simple paragraph text</p>
          <button>Simple button</button>
        </body>
      </html>
    '''));

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'data:text/html;charset=utf-8;base64,$encodedWebpage',
    );
  }
}
