package io.flutter.plugins.camera.types;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class FlashModeTest {

  @Test
  public void getValueForString_returns_correct_values() {
    assertEquals(
        "Returns FlashMode.off for 'off'", FlashMode.getValueForString("off"), FlashMode.off);
    assertEquals(
        "Returns FlashMode.auto for 'auto'", FlashMode.getValueForString("auto"), FlashMode.auto);
    assertEquals(
        "Returns FlashMode.always for 'always'",
        FlashMode.getValueForString("always"),
        FlashMode.always);
    assertEquals(
        "Returns FlashMode.torch for 'torch'",
        FlashMode.getValueForString("torch"),
        FlashMode.torch);
  }

  @Test
  public void getValueForString_returns_null_for_nonexistant_value() {
    assertEquals(
        "Returns null for 'nonexistant'", FlashMode.getValueForString("nonexistant"), null);
  }
}
