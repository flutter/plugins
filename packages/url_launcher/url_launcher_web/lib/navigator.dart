@JS()
library navigator.dart;

import 'package:js/js.dart';

@JS('window.navigator.standalone')
external bool get _standalone;

class Navigator {
  bool get standalone => _standalone ?? false;
}
