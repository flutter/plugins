import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new DrawerHeader(child: new Text('Drawer'))
            ],
          )
        ),
        appBar: new AppBar(
          title: const Text('WebView example app'),
        ),
        //body: const ToyBrowser(initialUrl: 'https://flutter.io'),
        body: const ToyBrowser(initialUrl: 'https://sketch.io/sketchpad'),
        //body: const ToyBrowser(initialUrl: 'https://youtube.com'),
        //body: const ToyBrowser(initialUrl: 'https://photos.app.goo.gl/5hKzYhqvpyb2swQT7'),
        //body: const ToyBrowser(initialUrl: 'https://www.google.com'),
      ),
    );
  }
}

class ToyBrowser extends StatefulWidget {

  const ToyBrowser({@required this.initialUrl});

  final String initialUrl;

  @override
  State<StatefulWidget> createState() => ToyBrowserState();

}

class ToyBrowserState extends State<ToyBrowser> {
  final WebControllerCompleter webControllerCompleter = new WebControllerCompleter();
  WebController webController;

  int transformIdx = 0;
  GlobalKey key = new GlobalKey();

  List<Matrix4> transforms = <Matrix4> [
    Matrix4.identity(),
    Matrix4.identity()
    ..rotateZ(math.pi / 3),
    // Matrix4.identity()
    // ..setEntry(3, 2, 0.001)
    // ..rotateX(0.7)
    // ..rotateY(0.2),
  ];

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new TextField(
          controller: new TextEditingController(text: widget.initialUrl),
          onSubmitted: (String newUrl) {
            webController?.loadUrl(newUrl);
          },
        ),
        new Row(
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: new RaisedButton(
                onPressed: () {
                  setState(() {
                    transformIdx = (transformIdx + 1) % transforms.length;
                  });
                },
                child: new Text('magic'),
              ),
            ),
          ],
        ),
        new Expanded(
          child: new GestureDetector(
            //behavior: HitTestBehavior.opaque,
            //onTap: () { print('tap detected'); },
            //onScaleStart: (e) { print('scale start'); },
            //onVerticalDragUpdate: (e) { print('vertical update'); },
            child: new Transform(
              transform: transforms[transformIdx],
              alignment: FractionalOffset.center,
              //child: Container(color: Colors.orange),
              child: new WebView(
                key: key,
                initialUrl: widget.initialUrl,
                webController: webControllerCompleter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    webControllerCompleter.future.then((WebController value) { webController = value; });
  }
}
