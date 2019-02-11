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
  List<Widget> list;

  @override
  void initState() {
    super.initState();
    _buildStorefront();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('IAP Example'),
          ),
          body: Center(
              child: list == null
                  ? Text('Loading...')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return list[index];
                      }))),
    );
  }

  _buildStorefront() async {
    await _buildConnectionCheckTile();
    await _buildProductList();
  }

  _buildConnectionCheckTile() async {
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
    }
    setState(() {
      list = children;
    });
  }

  _buildProductList() async {
    QueryProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(<String>[
      'consumable',
      'gas',
      'premium',
      'upgrade',
      'somethingNotValid'
    ].toSet());
    List<ListTile> productDetailsCards = response.productDetails.map(
      (ProductDetails productDetails) {
        return buildListCard(ListTile(
          title: Text(
            productDetails.title,
            style: TextStyle(color: ThemeData.dark().colorScheme.primary),
          ),
          subtitle: Text(productDetails.description,
              style: TextStyle(
                color: ThemeData.dark().colorScheme.secondary,
              )),
        ));
      },
    ).toList();
    setState(() {
      if (productDetailsCards.length > 0) {
        list.addAll(productDetailsCards);
      } else {
        list.add(buildListCard(ListTile(
          title: Text(
            'No matching products found',
            style: TextStyle(color: ThemeData.dark().colorScheme.primary),
          ),
        )));
      }
    });
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));
}
