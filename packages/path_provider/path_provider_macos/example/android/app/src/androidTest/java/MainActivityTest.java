
package io.flutter.plugins.pathprovider;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import io.flutter.plugins.pathproviderexample.MainActivity;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class);
}
