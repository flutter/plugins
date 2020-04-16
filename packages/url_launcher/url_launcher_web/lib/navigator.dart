@JS()
library navigator.dart;

import 'package:js/js.dart';

@JS('window.navigator.standalone')
external bool get _standalone;

/// Utility class to access the window.navigator DOM property.
class Navigator {
  /// The window.navigator.standalone DOM property.
  bool get standalone => _standalone ?? false;
}
