import 'package:integration_test/common.dart';
import 'package:integration_test/src/constants.dart';

const String _failureExcerpt = 'Expected: <true>';

bool isFailure(Object object) {
  if (object is! Failure) {
    return false;
  }
  final Failure failure = object as Failure;
  return failure.error.toString().contains(_failureExcerpt);
}

bool isSerializedFailure(dynamic object) =>
    object.toString().contains(_failureExcerpt);

bool isSuccess(Object object) => object == success;
