package io.flutter.plugins.localauth;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import io.flutter.embedding.android.FlutterFragmentActivity;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class FlutterFragmentActivityTest {
  @Rule
  public ActivityTestRule<FlutterFragmentActivity> rule =
      new ActivityTestRule<>(FlutterFragmentActivity.class);
}
