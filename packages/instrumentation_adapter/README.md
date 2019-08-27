# instrumentation_adapter

Adapts flutter_test results as Android instrumentation tests, making them usable for Firebase Test Lab and other Android CI providers.

iOS support is not available yet, but is planned in the future.

## Usage

Add a dependency on the `instrumentation_adapter` package in the `dev_dependencies` section of pubspec.yaml. For plugins, do this in the pubspec.yaml of the example app.

Invoke `InstrumentationAdapterFlutterBinding.ensureInitialized()` at the start of a test file.

```dart
import 'package:instrumentation_adapter/instrumentation_adapter.dart';
import '../test/package_info.dart' as test;

void main() {
  InstrumentationAdapterFlutterBinding.ensureInitialized();
  testWidgets("failing test example", (WidgetTester tester) async {
    expect(2 + 2, equals(5));
  });
}
```

Create an instrumentation test file in your application's
android/app/src/androidTest/java/com/example/myapp/ directory
(replacing com, example, and myapp with values from your app's
package name). You can name this test file MainActivityTest.java
or another name of your choice.

```
package com.example.myapp;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.instrumentationadapter.FlutterRunner;
import dev.flutter.plugins.instrumentationadapter.FlutterTest;
import java.lang.Override;
import org.junit.runner.RunWith;

@RunWith(FlutterRunner.class)
public class MainActivityTest extends FlutterTest {
  @Override
  public void launchActivity() {
    ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class);
    rule.launchActivity(null);
  }
}```

Use gradle commands to build an instrumentation test for Android.

```
pushd android
./gradlew assembleAndroidTest
./gradlew assembleDebug -Ptarget=<path_to_test>.dart
popd
```

Upload to Firebase Test Lab, making sure to replace <PATH_TO_KEY_FILE>, <PROJECT_NAME>, <RESULTS_BUCKET>, and <RESULTS_DIRECTORY> with your values.

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
