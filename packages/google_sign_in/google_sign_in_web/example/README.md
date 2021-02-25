# Testing

This package utilizes the `integration_test` package to run its tests in a web browser.

See [flutter.dev > Integration testing](https://flutter.dev/docs/testing/integration-tests) for more info.

## Running the tests

Make sure you have updated to the latest Flutter master.

1. Check what version of Chrome is running on the machine you're running tests on.

2. Download and install driver for that version from here:
    * <https://chromedriver.chromium.org/downloads>

3. Start the driver using `chromedriver --port=4444`

4. Run tests: `flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_driver.dart --target=integration_test/TEST_NAME.dart`, or (in Linux):

    * Single: `./run_test.sh integration_test/TEST_NAME.dart`
    * All: `./run_test.sh`
