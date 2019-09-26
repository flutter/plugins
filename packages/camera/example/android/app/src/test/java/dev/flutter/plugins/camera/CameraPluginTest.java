package dev.flutter.plugins.camera;

import org.junit.Test;

public class CameraPluginTest {
  @Test
  public void itDoesNothingWhenAttachedToFlutterEngineWithNoActivity() {
    final CameraPlugin cameraPlugin = new CameraPlugin();
    cameraPlugin.onAttachedToEngine(null);
    cameraPlugin.onDetachedFromEngine(null);

    // The fact that we get here without crashing means that nothing
    // significant is happening, because camera API access would crash
    // a JVM test.
  }
}
