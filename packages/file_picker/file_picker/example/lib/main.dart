import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

/// MyApp is the Main Application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'File Picker Demo Home Page'),
    );
  }
}

/// Home Page of the application
class MyHomePage extends StatefulWidget {
  
  /// Constructor for MyHomePage
  MyHomePage({Key key, this.title}) : super(key: key);

  /// Title of Home Page
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// State of Home Page
class _MyHomePageState extends State<MyHomePage> {
  String _msg = "";

  void _getMessage() async {
    String msg = await getMessage();
    setState(() {
      this._msg = "Here is your message: " + msg;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                this._msg
            ),
            SizedBox(height: 10),
            RaisedButton(
              child: Text('Press for a message and a file'),
              onPressed: () => { _getMessage() },
            ),
          ],
        ),
      ),
    );
  }
}
