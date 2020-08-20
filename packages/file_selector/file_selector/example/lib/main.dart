import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

void main() {
  runApp(MyApp());
}

/// MyApp is the Main Application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Selector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'File Selector Demo Home Page'),
      routes: {
        '/save' : (context) => SaveTest(title: "Save Example"),
        '/load' : (context) => LoadTest(title: "Load Example"),
      },
    );
  }
}


class SaveTest extends StatefulWidget {
  SaveTest({Key key, this.title}) : super(key: key);

  /// Title of Home Page
  final String title;

  @override
  _SaveTestState createState() => _SaveTestState();
}

class _SaveTestState extends State<SaveTest> {
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _extensionController = TextEditingController();

  @override
  void dispose() {
    _fileController.dispose();
    super.dispose();
  }

  void _saveFile() async {
    Uint8List data;
    data = Uint8List.fromList(_fileController.text.codeUnits);

    XFile new_file;
    XType type = XType(extension: '.txt');

    if (_nameController.text == '') {
      new_file = XFile.fromData(data, type: type);
    } else {
      new_file = XFile.fromData(data, type: type, name: _nameController.text);
    }

    new_file.saveTo('');
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
            Container(
              width: 300,
              child: TextField(
                minLines: 1,
                maxLines: 12,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '(Optional) Suggest File Name',
                ),
              ),
            ),
            Container(
              width: 300,
              child: TextField(
                minLines: 1,
                maxLines: 12,
                controller: _fileController,
                decoration: InputDecoration(
                  hintText: 'Enter File Contents',
                ),
              ),
            ),
            SizedBox(height: 10),
            RaisedButton(
              child: Text('Press to save file'),
              onPressed: () => { _saveFile() },
            ),
          ],
        ),
      ),
    );
  }
}

class LoadTest extends StatefulWidget {
  LoadTest({Key key, this.title}) : super(key: key);

  /// Title of Home Page
  final String title;


  @override
  _LoadTestState createState() => _LoadTestState();
}

class _LoadTestState extends State<LoadTest> {
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _extensionController = TextEditingController();

  void _loadFile() async {
    XFile file;
    if (_extensionController.text.isNotEmpty) {
      List<XTypeGroup> typeGroups = List();

      List<XType> types = List();
      _extensionController.text.split(',').forEach((type) => types.add(XType(extension: type)));

      typeGroups.add(XTypeGroup(label: 'Example Files', fileTypes: types));
      file = await loadFile(acceptedTypeGroups: typeGroups);
    } else {
      file = await loadFile();
    }

    String text = await file.readAsString();

    _fileController.text = text;

    if (file.name.isNotEmpty) {
      _nameController.text = file.name;
    }
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
            Container(
              width: 300,
              child: TextField(
                enabled: false,
                minLines: 1,
                maxLines: 12,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'File Name Will Appear Here',
                ),
              ),
            ),
            Container(
              width: 300,
              child: TextField(
                enabled: false,
                minLines: 1,
                maxLines: 12,
                controller: _fileController,
                decoration: InputDecoration(
                  hintText: 'File Contents Will Appear Here',
                ),
              ),
            ),
            Container(
              width: 300,
              child: TextField(
                controller: _extensionController,
                decoration: InputDecoration(
                  hintText: '(Optional) Accepted Load Extensions',
                ),
              ),
            ),
            RaisedButton(
              child: Text('Press to load a file'),
              onPressed: () => { _loadFile() },
            ),
          ],
        ),
      ),
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

            SizedBox(height: 10),
            RaisedButton(
              child: Text('Press to try saving a file'),
              onPressed: () => Navigator.pushNamed(context, '/save'),
            ),
            RaisedButton(
              child: Text('Press to try loading a file'),
              onPressed: () => Navigator.pushNamed(context, '/load'),
            ),
          ],
        ),
      ),
    );
  }

}
