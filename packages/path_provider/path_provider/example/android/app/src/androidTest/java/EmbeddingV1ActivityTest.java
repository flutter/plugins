
package io.flutter.plugins.pathprovider;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import io.flutter.plugins.pathproviderexample.EmbeddingV1Activity;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class EmbeddingV1ActivityTest {
  @Rule
  public ActivityTestRule<EmbeddingV1Activity> rule =
      new ActivityTestRule<>(EmbeddingV1Activity.class);
}
