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
        body: Column(
          children: [
            FutureBuilder(
              future: _buildConnectionCheckTile(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Column(children: <Widget>[
                    buildListCard(
                        ListTile(title: const Text('Trying to connect...')))
                  ]);
                } else if (snapshot.error != null) {
                  return Column(children: <Widget>[
                    buildListCard(ListTile(
                        title: Text(
                            'Error connecting: ' + snapshot.error.toString())))
                  ]);
                }
                return Column(
                  children: snapshot.data,
                );
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: InAppPurchaseConnection.instance.queryProductDetails(
                    <String>['consumable', 'upgrade', 'subscription'].toSet()),
                builder: (BuildContext context,
                    AsyncSnapshot<ProductDetailsResponse> snapshot) {
                  if (!snapshot.hasData) {
                    return Column(children: <Widget>[
                      buildListCard(ListTile(title: const Text('Loading...')))
                    ]);
                  } else if (snapshot.error != null) {
                    return Center(
                      child: Text('Error: ' + snapshot.error.toString()),
                    );
                  }
                  return Column(
                    children: <Widget>[
                      Center(child: Text('Products')),
                      Expanded(
                        child: ListView(
                          children: _buildProductList(snapshot.data),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ListTile>> _buildConnectionCheckTile() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    final Widget storeHeader = buildListCard(
      ListTile(
        leading: Icon(available ? Icons.check : Icons.block),
        title: Text(
            'The store is ' + (available ? 'available' : 'unavailable') + '.'),
      ),
    );
    final List<ListTile> children = <ListTile>[storeHeader];

    if (!available) {
      children.add(
        buildListCard(
          ListTile(
            title: Text('Not connected',
                style: TextStyle(color: ThemeData.light().errorColor)),
            subtitle: const Text(
                'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
          ),
        ),
      );
    }
    return children;
  }

  List<ListTile> _buildProductList(ProductDetailsResponse response) {
    List<ListTile> productDetailsCards = response.productDetails.map(
      (ProductDetails productDetails) {
        return buildListCard(ListTile(
          title: Text(
            productDetails.title,
          ),
          subtitle: Text(
            productDetails.description,
          ),
          trailing: Text(productDetails.price),
        ));
      },
    ).toList();
    return productDetailsCards;
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));
}
