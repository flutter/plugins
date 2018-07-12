import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('WebView example app'),
        ),
        body: const ToyBrowser(initialUrl: 'https://flutter.io'),
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
        new Expanded(
          child: new WebView(
            initialUrl: widget.initialUrl,
            webController: webControllerCompleter,
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    webControllerCompleter.future.then((WebController value) { webController = value; });
  }
}
