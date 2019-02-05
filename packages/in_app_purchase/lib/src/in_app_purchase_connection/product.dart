// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

class Product {

  Product({
    @required this.productIdentifier,
    @required this.title,
    @required this.description,
    @required this.price,
  });

  final String productIdentifier;
  final String title;
  final String description;
  final String price;
}