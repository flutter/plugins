// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase_connection.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
        ),
        body: Center(
            child: FutureBuilder<List<Widget>>(
                future: buildStorefront(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Widget>> snapshot) {
                  if (!snapshot.hasData) {
                    return ListView(children: <Widget>[
                      buildListCard(
                          ListTile(title: const Text('Trying to connect...')))
                    ]);
                  } else if (snapshot.error != null) {
                    return ListView(children: <Widget>[
                      buildListCard(ListTile(
                          title: Text('Error connecting: ' +
                              snapshot.error.toString())))
                    ]);
                  }

                  return ListView(children: snapshot.data);
                })),
      ),
    );
  }

  Future<List<Widget>> buildStorefront() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    final Widget storeHeader = buildListCard(ListTile(
        leading: Icon(available ? Icons.check : Icons.block),
        title: Text('The store is ' +
            (available ? 'available' : 'unavailable') +
            '.')));
    final List<Widget> children = <Widget>[storeHeader];

    if (!available) {
      children.add(buildListCard(ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'))));
    } else {
      children.add(
          buildListCard(ListTile(title: const Text('Nothing to see yet.'))));
    }

    return children;
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));
}
