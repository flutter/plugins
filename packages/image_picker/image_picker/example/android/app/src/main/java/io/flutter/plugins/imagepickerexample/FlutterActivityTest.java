package io.flutter.plugins.imagepickerexample;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.e2e.FlutterRunner;
import io.flutter.embedding.android.FlutterActivity;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterRunner.class)
public class FlutterActivityTest {
  @Rule
  public ActivityTestRule<FlutterActivity> rule = new ActivityTestRule<>(FlutterActivity.class);
}
