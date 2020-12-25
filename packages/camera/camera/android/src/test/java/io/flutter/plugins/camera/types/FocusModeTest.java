package io.flutter.plugins.camera.types;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class FocusModeTest {

  @Test
  public void getValueForString_returns_correct_values() {
    assertEquals(
        "Returns FocusMode.continuous for 'continuous'", FocusMode.getValueForString("continuous"), FocusMode.continuous);
    assertEquals(
        "Returns FocusMode.auto for 'auto'",
        FocusMode.getValueForString("auto"),
        FocusMode.auto);
  }

  @Test
  public void getValueForString_returns_null_for_nonexistant_value() {
    assertEquals(
        "Returns null for 'nonexistant'", FocusMode.getValueForString("nonexistant"), null);
  }

  @Test
  public void toString_returns_correct_value() {
    assertEquals("Returns 'continuous' for FocusMode.continuous", FocusMode.continuous.toString(), "continuous");
    assertEquals("Returns 'auto' for FocusMode.auto", FocusMode.auto.toString(), "auto");
  }
}
