@JS()
library navigator;

import 'package:js/js.dart';
import 'package:meta/meta.dart';

@JS('window.navigator.standalone')
external bool get _standalone;

/// The window.navigator.standalone DOM property.
bool get standalone => _standalone ?? false;

@visibleForTesting
@JS('window.navigator.standalone')
external set standalone(bool enabled);
