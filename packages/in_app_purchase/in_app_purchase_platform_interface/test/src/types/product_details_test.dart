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
}
