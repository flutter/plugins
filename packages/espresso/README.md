# espresso

A new flutter plugin project.

This package provides bindings for Espresso tests of Flutter apps.

## Installation

See the example app for test layout.

Add ```android:usesCleartextTraffic="true"``` to your ```<application>``` in your AndroidManifest.xml.

## Sample usage:

```
@RunWith(AndroidJUnit4.class)
public final class SharedPreferencesIntegrationTest {

 @Rule
 public ActivityTestRule<MainActivity> myActivityTestRule =
           new ActivityTestRule<>(MainActivity.class, true, false);

 @Before
 public void setUp() {
   ActivityScenario.launch(MainActivity.class);
 }

 @Test
 public void tapToCheckPersistentData() throws Exception {
   onFlutterWidget(FlutterMatchers.withTooltip("Clear")).perform(FlutterActions.click());
   onFlutterWidget(FlutterMatchers.withTooltip("Increment")).perform(FlutterActions.click());
   onFlutterWidget(FlutterMatchers.withValueKey("ResultText")).check(
     FlutterAssertions.matches(FlutterMatchers.withText(
       "Button tapped 1 time.\n\nThis should persist across restarts."
     )));
   // kill the app
   pressBackUnconditionally();
   // reopen the application
   myActivityTestRule.launchActivity(null);
   onFlutterWidget(FlutterMatchers.withValueKey("ResultText")).check(
      FlutterAssertions.matches(
      FlutterMatchers.withText(
      "Button tapped 1 time.\n\nThis should persist across restarts.")));
   }
}
```

The following command line command runs the test locally:

```
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../test_driver/shared_preferences.dart
```

Tests can also be uploaded to Firebase Test Lab:

```
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

This guarantees that UrlLauncherPlatform.instance cannot be set to an object that `implements`
UrlLauncherPlatform (it can only be set to an object that `extends` UrlLauncherPlatform).

