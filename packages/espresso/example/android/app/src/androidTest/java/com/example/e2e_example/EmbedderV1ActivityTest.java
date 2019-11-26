package com.example.espresso_example;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.espresso.FlutterRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterRunner.class)
public class EmbedderV1ActivityTest {
  @Rule
  public ActivityTestRule<EmbedderV1Activity> rule =
      new ActivityTestRule<>(EmbedderV1Activity.class);
}
