package io.flutter.plugins.googlemaps;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.e2e.FlutterRunner;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugins.DartIntegrationTest;
import org.junit.Rule;
import org.junit.runner.RunWith;

<<<<<<< HEAD:packages/google_maps_flutter/google_maps_flutter/example/android/app/src/androidTest/java/io/flutter/plugins/googlemaps/MainActivityTest.java
@RunWith(FlutterRunner.class)
=======
@DartIntegrationTest
@RunWith(FlutterTestRunner.class)
>>>>>>> b401c84200bccd2b4747c2273ea5e13802dd569f:packages/google_maps_flutter/google_maps_flutter/example/android/app/src/androidTest/java/io/flutter/plugins/googlemapsexample/MainActivityTest.java
public class MainActivityTest {
  @Rule
  public ActivityTestRule<FlutterActivity> rule = new ActivityTestRule<>(FlutterActivity.class);
}
