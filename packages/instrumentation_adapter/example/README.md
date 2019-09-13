# instrumentation_adapter_example

Demonstrates how to use the instrumentation_adapter plugin.

## Testing options

Below demonstrates the options of running a Flutter test.

1.  Execute `flutter test` to run the unit tests in *test* directory off device.
1.  Execute `flutter drive -t test_driver/widget.dart` to run a driver test on
    an attached device.
1.  Execute `flutter run -t test/widget_test.dart` to run the test on an
    attached device.
1.  Execute `pushd android && ./gradlew connectedAndroidTest
    -Ptarget=test_adapter/widget_test.dart && popd` to run the test on an
    attached device, and report result to Android instrumentation.
