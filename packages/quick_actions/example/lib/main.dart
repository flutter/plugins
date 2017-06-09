import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';

  @override
  initState() {
    super.initState();
    var quickActions = const QuickActions();
    quickActions.initialize((shortcutType) {
      if (shortcutType == 'action_main') {
        print('The user tapped on the "Main view" action.');
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      new ShortcutItem(type: 'action_main', localizedTitle: 'Main view', icon: 'AppIcon'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Plugin example app'),
      ),
      body: new Center(child: new Text('On home screen, long press the icon to '
      'get Main view action. Tapping on that action should print '
      'a message to the log.')),
    );
  }
}
