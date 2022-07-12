package io.flutter.plugins.imagepickerexample;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import org.jetbrains.annotations.NotNull;

public class DriverExtensionActivity extends FlutterActivity {
  @NonNull
  @NotNull
  @Override
  public String getDartEntrypointFunctionName() {
    return "appMain";
  }
}
