import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase_connection.dart';

const List<String> _kProductIds = <String>[
  'consumable',
  'upgrade',
  'subscription'
];

class ProductList extends StatefulWidget {
  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  final String username = 'a user name';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        FutureBuilder(
          future: _buildConnectionCheckTile(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.error != null) {
              return buildListCard(ListTile(
                  title:
                      Text('Error connecting: ' + snapshot.error.toString())));
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

    Map<String, PurchaseDetails> purchases = Map.fromEntries((await connection
            .queryPastPurchases())
        .map((PurchaseDetails purchase) =>
            MapEntry<String, PurchaseDetails>(purchase.productId, purchase)));

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
              : Text(productDetails.price),
          onTap: () async {
            PurchaseResponse response =
                await InAppPurchaseConnection.instance.makePayment(
              productID: productDetails.id,
              applicationUserName: username,
            );
            String text = response.status == PurchaseStatus.purchased
                ? 'Purchase successful'
                : 'Purchase failed with error ${response.error}';
            final snackBar = SnackBar(
              content: Text(text),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
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
