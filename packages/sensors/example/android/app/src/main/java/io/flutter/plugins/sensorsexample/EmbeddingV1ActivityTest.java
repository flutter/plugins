package io.flutter.plugins.sensorsexample;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integrationTest.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class EmbeddingV1ActivityTest {
  @Rule
  public ActivityTestRule<EmbeddingV1Activity> rule =
      new ActivityTestRule<>(EmbeddingV1Activity.class);
}
