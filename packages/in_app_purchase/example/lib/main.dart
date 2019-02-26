// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase_connection.dart';

void main() => runApp(MyApp());

const List<String> _kProductIds = <String>[
  'consumable',
  'upgrade',
  'subscription'
];

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
        body: ListView(
          children: [
            FutureBuilder(
              future: _buildConnectionCheckTile(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.error != null) {
                  return buildListCard(ListTile(
                      title: Text(
                          'Error connecting: ' + snapshot.error.toString())));
                } else if (!snapshot.hasData) {
                  return Card(
                      child:
                          ListTile(title: const Text('Trying to connect...')));
                }
                return snapshot.data;
              },
            ),
            FutureBuilder(
              future: _buildProductList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.error != null) {
                  return Center(
                    child: buildListCard(ListTile(
                        title: Text('Error fetching products'),
                        subtitle: snapshot.error)),
                  );
                } else if (!snapshot.hasData) {
                  return Card(
                      child: (ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Fetching products...'))));
                }
                return snapshot.data;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Card> _buildConnectionCheckTile() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    final Widget storeHeader = ListTile(
      leading: Icon(available ? Icons.check : Icons.block,
          color: available ? Colors.green : ThemeData.light().errorColor),
      title: Text(
          'The store is ' + (available ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!available) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Future<Card> _buildProductList() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    if (!available) {
      return Card();
    }
    final ListTile productHeader = ListTile(
        title: Text('Products for Sale',
            style: Theme.of(context).textTheme.headline));
    ProductDetailsResponse response = await InAppPurchaseConnection.instance
        .queryProductDetails(_kProductIds.toSet());
    List<ListTile> productList = <ListTile>[];
    if (!response.notFoundIDs.isEmpty) {
      productList.add(ListTile(
          title: Text('[${response.notFoundIDs.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    productList.addAll(response.productDetails.map(
      (ProductDetails productDetails) {
        return ListTile(
          title: Text(
            productDetails.title,
          ),
          subtitle: Text(
            productDetails.description,
          ),
          trailing: Text(productDetails.price),
        );
      },
    ));

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));
}
