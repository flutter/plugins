# e2e

This package enables self-driving testing of Flutter code on devices and emulators.
It can adapt the test results in a format that is compatible with `flutter drive`
and native Android instrumentation testing.

iOS support is not available yet, but is planned in the future.

## Usage

Add a dependency on the `e2e` package in the
`dev_dependencies` section of pubspec.yaml. For plugins, do this in the
pubspec.yaml of the example app.

Invoke `E2EWidgetsFlutterBinding.ensureInitialized()` at the start
of a test file, e.g.

```dart
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  testWidgets("failing test example", (WidgetTester tester) async {
    expect(2 + 2, equals(5));
  });
  exit(result == 'pass' ? 0 : 1);
}
```

## Using Flutter driver to run tests

`E2EWidgetsTestBinding` supports launching the on-device tests with `flutter drive`.
Note that the tests don't use the `FlutterDriver` API, they use `testWidgets` instead.

Put the a file named `<package_name>_test.dart` in the app' `test_driver` directory:

```
import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  await driver.requestData(null, timeout: const Duration(minutes: 1));
  driver.close();
  exit(result == 'pass' ? 0 : 1);
}
```

To run a example app test with Flutter driver:

```
cd example
flutter drive test/<package_name>_e2e.dart
```

To test plugin APIs using Flutter driver:

```
cd example
flutter drive --driver=test_driver/<package_name>_test.dart test/<package_name>_e2e.dart
```

## Android device testing

Create an instrumentation test file in your application's
**android/app/src/androidTest/java/com/example/myapp/** directory (replacing
com, example, and myapp with values from your app's package name). You can name
this test file MainActivityTest.java or another name of your choice.

```
package com.example.myapp;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.e2e.FlutterRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class);
}
```

Update your application's **myapp/android/app/build.gradle** to make sure it
uses androidx's version of AndroidJUnitRunner and has androidx libraries as a
dependency.

```
android {
  ...
  defaultConfig {
    ...
    testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
  }
}

dependencies {
    testImplementation 'junit:junit:4.12'

    // https://developer.android.com/jetpack/androidx/releases/test/#1.2.0
    androidTestImplementation 'androidx.test:runner:1.2.0'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.2.0'
}
```

To e2e test on a local Android device (emulated or physical):

```
./gradlew connectedAndroidTest -Ptarget=`pwd`/../test_driver/<package_name>_e2e.dart
```

## Firebase Test Lab

To run an e2e test on Android devices using Firebase Test Lab, use gradle commands to build an
instrumentation test for Android.

```
pushd android
./gradlew assembleAndroidTest
./gradlew assembleDebug -Ptarget=<path_to_test>.dart
popd
```

Upload to Firebase Test Lab, making sure to replace <PATH_TO_KEY_FILE>,
<PROJECT_NAME>, <RESULTS_BUCKET>, and <RESULTS_DIRECTORY> with your values.

```
gcloud auth activate-service-account --key-file=<PATH_TO_KEY_FILE>
gcloud --quiet config set project <PROJECT_NAME>
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk\
  --timeout 2m \
  --results-bucket=<RESULTS_BUCKET> \
  --results-dir=<RESULTS_DIRECTORY>
```

iOS support for Firebase Test Lab is not yet available, but is planned.
