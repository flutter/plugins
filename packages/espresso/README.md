# espresso

Provides bindings for Espresso tests of Flutter Android apps.

|             | Android |
|-------------|---------|
| **Support** | SDK 16+ |

## Installation

Add the `espresso` package as a `dev_dependency` in your app's pubspec.yaml. If you're testing the example app of a package, add it as a dev_dependency of the main package as well.

Add ```android:usesCleartextTraffic="true"``` in the ```<application>``` in the AndroidManifest.xml
of the Android app used for testing. It's best to put this in a debug or androidTest
AndroidManifest.xml so that you don't ship it to end users. (See the example app of this package.)

Add the following dependencies in android/app/build.gradle:

```groovy
dependencies {
    testImplementation 'junit:junit:4.13.2'
    testImplementation "com.google.truth:truth:1.0"
    androidTestImplementation 'androidx.test:runner:1.1.1'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.1.1'
    api 'androidx.test:core:1.2.0'
}
```

Create an `android/app/src/androidTest` folder and put a test file in a package-appropriate subfolder, e.g. `android/app/src/androidTest/java/com/example/MainActivityTest.java`:

```java
package com.example.espresso_example;

import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.action.FlutterActions.syntheticClick;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isDescendantOf;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withTooltip;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withType;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import static com.google.common.truth.Truth.assertThat;
import static org.junit.Assert.fail;

import androidx.test.core.app.ActivityScenario;
import androidx.test.espresso.flutter.EspressoFlutter.WidgetInteraction;
import androidx.test.espresso.flutter.assertion.FlutterAssertions;
import androidx.test.espresso.flutter.matcher.FlutterMatchers;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Unit tests for {@link EspressoFlutter}. */
@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

    @Before
    public void setUp() throws Exception {
        ActivityScenario.launch(MainActivity.class);
    }

    @Test
    public void performClick() {
        onFlutterWidget(withTooltip("Increment")).perform(click());
        onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 1 time.")));
    }
 ```

You'll need to create a test app that enables the Flutter driver extension.
You can put this in your test_driver/ folder, e.g. test_driver/example.dart.
Replace `<app_package_name>` with the package name of your app. If you're
developing a plugin, this will be the package name of the example app.

```dart
import 'package:flutter_driver/driver_extension.dart';
import 'package:<app_package_name>/main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
```

The following command line command runs the test locally:

```sh
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../test_driver/example.dart
```

Espresso tests can also be run on [Firebase Test Lab](https://firebase.google.com/docs/test-lab):

```sh
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=<path_to_test>.dart
gcloud auth activate-service-account --key-file=<PATH_TO_KEY_FILE>
gcloud --quiet config set project <PROJECT_NAME>
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk\
  --timeout 2m \
  --results-bucket=<RESULTS_BUCKET> \
  --results-dir=<RESULTS_DIRECTORY>
```
