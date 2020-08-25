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

/// Page for showing an example of saving with file_selector
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
    String path = await getSavePath();

    Uint8List data;
    data = Uint8List.fromList(_fileController.text.codeUnits);

    XFile new_file;
    XType type = XType(extension: '.txt');

    if (_nameController.text == '') {
      new_file = XFile.fromData(data, type: type);
    } else {
      new_file = XFile.fromData(data, type: type, name: _nameController.text + '.txt');
    }

    new_file.saveTo(path);
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
              child: Text('Press to save a text file'),
              onPressed: () => { _saveFile() },
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen that shows an example of loadFile(s)
class LoadTest extends StatefulWidget {
  /// Default constructor
  LoadTest({Key key, this.title}) : super(key: key);

  /// Title of Home Page
  final String title;


  @override
  _LoadTestState createState() => _LoadTestState();
}

class _LoadTestState extends State<LoadTest> {
  final TextEditingController _extensionController = TextEditingController();

  void _onLoadImageFile() async {
    XType jpg = XType(extension: '.jpg');
    XType png = XType(extension: '.png');
    XTypeGroup typeGroup = XTypeGroup(label: 'images', fileTypes: [ jpg, png ]);

    XFile file = await loadFile(acceptedTypeGroups: [ typeGroup ]);

    await showDialog(
      context: context,
      builder: (context) {
        return ImageDisplay(file: file);
      }
    );


  }

  void _onLoadTextFile() async {
    XType txt = XType(extension: '.txt');
    XType json = XType(extension: '.json');
    XTypeGroup typeGroup = XTypeGroup(label: 'images', fileTypes: [ txt, json ]);

    XFile file = await loadFile(acceptedTypeGroups: [typeGroup]);

    await showDialog(
        context: context,
        builder: (context) {
          return TextDisplay(file: file);
        }
    );
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
            RaisedButton(
              child: Text('Press to load an image file(png, jpg)'),
              onPressed: () => _onLoadImageFile(),
            ),
            RaisedButton(
              child: Text('Press to load a text file (json, txt)'),
              onPressed: () => _onLoadTextFile(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog
class TextDisplay extends StatefulWidget {
  /// File to display
  final XFile file;

  /// Default Constructor
  TextDisplay({Key key, @required this.file}) : super(key: key);

  @override
  _TextDisplayState createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  String fileContents;

  @override
  void initState() {
    super.initState();
    _getFileContents();
  }

  void _getFileContents() async {
    String contents = await widget.file.readAsString();
    setState(() => fileContents = contents);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.file.name),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Text(
            fileContents ?? 'Loading file contents...\nThis may take a while if your file is large.',
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

/// Widget that displays a text file in a dialog
class ImageDisplay extends StatefulWidget {
  /// File to display
  final XFile file;

  /// Default Constructor
  ImageDisplay({Key key, @required this.file}) : super(key: key);

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.file.name),
      content: Image.network(widget.file.path),

      actions: [
        FlatButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
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
