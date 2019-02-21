// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase_connection.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SKPaymentQueueWrapper().setTransactionObserver(MyObserver());
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
                if (snapshot.error != null) {
                  return Column(children: <Widget>[
                    buildListCard(ListTile(
                        title: Text(
                            'Error connecting: ' + snapshot.error.toString())))
                  ]);
                } else if (!snapshot.hasData) {
                  return Column(children: <Widget>[
                    buildListCard(
                        ListTile(title: const Text('Trying to connect...')))
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
                  if (snapshot.error != null) {
                    return Center(
                      child: Text('Error: ' + snapshot.error.toString()),
                    );
                  } else if (!snapshot.hasData) {
                    return Column(children: <Widget>[
                      buildListCard(ListTile(title: const Text('Loading...')))
                    ]);
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
          onTap: () {
            SKPaymentWrapper payment = SKPaymentWrapper(
                productIdentifier: productDetails.id,
                applicationUsername: '',
                quantity: 1,
                simulatesAskToBuyInSandbox: true,
                requestData: null);
            SKPaymentQueueWrapper().addPayment(payment);
          },
        ));
      },
    ).toList();
    return productDetailsCards;
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));
}

class MyObserver extends SKTransactionObserverWrapper {
  void updatedTransaction({List<SKPaymentTransactionWrapper> transactions}) {
    print('updatedTransaction');
  }

  void removedTransaction({List<SKPaymentTransactionWrapper> transactions}) {
    print('removedTransaction');
  }

  void restoreCompletedTransactions({Error error}) {
    print('restoreCompletedTransactions');
  }

  void paymentQueueRestoreCompletedTransactionsFinished() {
    print('restore completed transactions finished');
  }

  void updatedDownloads({List<SKDownloadWrapper> downloads}) {
    print('updatedDownloads');
  }

  bool shouldAddStorePayment(
      {SKPaymentWrapper payment, SKProductWrapper product}) {
    print('shouldAddStorePayment');
    return true;
  }
}
