// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

void main() {
  group('Constructor Tests', () {
    test(
        'fromSkProduct should correctly parse data from a SKProductWrapper instance.',
        () {
      final ProductDetails productDetails = ProductDetails(
          id: 'id',
          title: 'title',
          description: 'description',
          price: '13.37',
          currencyCode: 'USD',
          currencySymbol: r'$',
          rawPrice: 13.37);

      expect(productDetails.id, 'id');
      expect(productDetails.title, 'title');
      expect(productDetails.description, 'description');
      expect(productDetails.rawPrice, 13.37);
      expect(productDetails.currencyCode, 'USD');
      expect(productDetails.currencySymbol, r'$');
    });
  });

  group('PurchaseStatus Tests', () {
    test('PurchaseStatus should contain 5 options', () {
      const List<PurchaseStatus> values = PurchaseStatus.values;

      expect(values.length, 5);
    });

    test('PurchaseStatus enum should have items in correct index', () {
      const List<PurchaseStatus> values = PurchaseStatus.values;

      expect(values[0], PurchaseStatus.pending);
      expect(values[1], PurchaseStatus.purchased);
      expect(values[2], PurchaseStatus.error);
      expect(values[3], PurchaseStatus.restored);
      expect(values[4], PurchaseStatus.canceled);
    });
  });
}
