///
//  Generated code. Do not modify.
///
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: library_prefixes
library fble_pbenum;

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, dynamic, String, List, Map;
import 'package:protobuf/protobuf.dart';

class GetLocalAdaptersResponse_Platform extends ProtobufEnum {
  static const GetLocalAdaptersResponse_Platform ANDROID = const GetLocalAdaptersResponse_Platform._(0, 'ANDROID');
  static const GetLocalAdaptersResponse_Platform IOS = const GetLocalAdaptersResponse_Platform._(1, 'IOS');

  static const List<GetLocalAdaptersResponse_Platform> values = const <GetLocalAdaptersResponse_Platform> [
    ANDROID,
    IOS,
  ];

  static final Map<int, dynamic> _byValue = ProtobufEnum.initByValue(values);
  static GetLocalAdaptersResponse_Platform valueOf(int value) => _byValue[value] as GetLocalAdaptersResponse_Platform;
  static void $checkItem(GetLocalAdaptersResponse_Platform v) {
    if (v is! GetLocalAdaptersResponse_Platform) checkItemFailed(v, 'GetLocalAdaptersResponse_Platform');
  }

  const GetLocalAdaptersResponse_Platform._(int v, String n) : super(v, n);
}

