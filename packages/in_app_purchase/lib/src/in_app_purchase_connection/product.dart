import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:flutter/foundation.dart';

class Product {
  Product({@required this.skProduct});

  final SKProductWrapper skProduct;
}