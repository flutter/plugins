// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import './product_list.dart';
import 'package:in_app_purchase/in_app_purchase_connection.dart';

void main() {
  PurchaseUpdateListener updateListener = (
      {PurchaseDetails purchaseDetails,
      PurchaseStatus status,
      PurchaseError error}) {
    if (error != null) {
      print('purchase error ${error.message}');
    }
  };

  StorePaymentDecisionMaker decisionMaker =
      ({ProductDetails productDetails, String applicationUserName}) {
    return true;
  };

  InAppPurchaseConnection.configure(
    purchaseUpdateListener: updateListener,
    storePaymentDecisionMaker: decisionMaker,
  );
  runApp(MyApp());
}

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
        body: ProductList(),
      ),
    );
  }
}
