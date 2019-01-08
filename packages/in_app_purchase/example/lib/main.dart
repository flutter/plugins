import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _storeReady = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final InAppPurchasePlugin plugin = InAppPurchasePlugin();
    final bool connected = await plugin.connection.connect();
    setState(() {
      _storeReady = connected;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final Widget storeHeader = buildListCard(ListTile(
        leading: Icon(_storeReady ? Icons.check : Icons.block),
        title:
            Text('The store is ' + (_storeReady ? 'open' : 'closed') + '.')));
    final List<Widget> children = <Widget>[storeHeader];

    if (!_storeReady) {
      children.add(buildListCard(ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'))));
    } else {
      children.add(
          buildListCard(ListTile(title: const Text('Nothing to see yet.'))));
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
        ),
        body: Center(child: ListView(children: children)),
      ),
    );
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));
}
