// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase_connection.dart';

void main() {
  runApp(MyApp());
}

// Switch this to true if you want to try out auto consume when buying a consumable.
const bool kAutoConsume = false;

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
  StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _purchasePending = false;
  @override
  void initState() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    stack.add(
      ListView(
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
                    child: ListTile(title: const Text('Trying to connect...')));
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
                      title:
                          Text('Error fetching products ${snapshot.error}'))),
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
    );
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            new Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            new Center(
              child: new CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
        ),
        body: Stack(
          children: stack,
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
    InAppPurchaseConnection connection = InAppPurchaseConnection.instance;
    final bool available = await connection.isAvailable();
    if (!available) {
      return Card();
    }
    final ListTile productHeader = ListTile(
        title: Text('Products for Sale',
            style: Theme.of(context).textTheme.headline));
    ProductDetailsResponse response =
        await connection.queryProductDetails(_kProductIds.toSet());
    List<ListTile> productList = <ListTile>[];
    if (!response.notFoundIDs.isEmpty) {
      productList.add(ListTile(
          title: Text('[${response.notFoundIDs.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verity the purchase data.
    Map<String, PurchaseDetails> purchases = Map.fromEntries(
        ((await connection.queryPastPurchases()).pastPurchases)
            .map((PurchaseDetails purchase) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      if (Platform.isAndroid && purchase.productID == 'consumable') {
        InAppPurchaseConnection.instance.consumePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(response.productDetails.map(
      (ProductDetails productDetails) {
        PurchaseDetails previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? Icon(Icons.check)
                : FlatButton(
                    child: Text(productDetails.price),
                    color: Colors.green[800],
                    textColor: Colors.white,
                    onPressed: () {
                      PurchaseParam purchaseParam = PurchaseParam(
                          productDetails: productDetails,
                          applicationUserName: null,
                          sandboxTesting: true);
                      if (productDetails.id == 'consumable') {
                        connection.buyConsumable(
                            purchaseParam: purchaseParam,
                            autoConsume: kAutoConsume || Platform.isIOS);
                      } else {
                        connection.buyNonConsumable(
                            purchaseParam: purchaseParam);
                      }
                    },
                  ));
      },
    ));

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase purchase details before deliver the product.
    setState(() {
      _purchasePending = false;
    });
  }

  void handleError(PurchaseError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (Platform.isIOS) {
          InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
        } else if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == 'consumable') {
            InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
          }
        }
      }
    });
  }
}
