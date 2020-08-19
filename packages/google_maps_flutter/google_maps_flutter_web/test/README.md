# Running browser_tests

Make sure you have updated to the latest Flutter master.

1. Check what version of Chrome is running on the machine you're running tests on.

2. Download and install driver for that version from here:
    * <https://chromedriver.chromium.org/downloads>

3. Start the driver using `chromedriver --port=4444`

4. Change into the `test` directory of your clone.

5. Run tests: `flutter drive -d web-server --browser-name=chrome --target=test_driver/TEST_NAME_e2e.dart`, or (in Linux):

    * Single: `./run_test test_driver/TEST_NAME_e2e.dart`
    * All: `./run_test`
