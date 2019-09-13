import 'package:instrumentation_adapter/instrumentation_adapter.dart';
import '../test/widget_test.dart' as unit_test;

void main() {
  InstrumentationAdapterFlutterBinding.ensureInitialized();
  unit_test.main();
}
