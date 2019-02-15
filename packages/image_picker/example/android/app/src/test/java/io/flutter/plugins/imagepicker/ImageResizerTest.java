package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class ImageResizerTest {

  private void doCheck(
      int originalWidth, int originalHeight,
      Double maxWidth, Double maxHeight, boolean crop,
      int expectedWidth, int expectedHeight,
      double expectedScale,
      double expectedDrawX, double expectedDrawY,
      double expectedDrawWidth, double expectedDrawHeight
  ) {
    ImageResizer.SizeInfo info = ImageResizer.computeSizeInfo(originalWidth, originalHeight, maxWidth, maxHeight, crop);
    assertEquals(expectedWidth, info.width);
    assertEquals(expectedHeight, info.height);
    assertEquals(expectedScale, info.scale, 0);
    assertEquals(expectedDrawX, info.drawX, 0);
    assertEquals(expectedDrawY, info.drawY, 0);
    assertEquals(expectedDrawWidth, info.drawWidth, 0);
    assertEquals(expectedDrawHeight, info.drawHeight, 0);
  }

  private void check(
      int originalWidth, int originalHeight,
      Double maxWidth, Double maxHeight, boolean crop,
      int expectedWidth, int expectedHeight,
      double expectedScale,
      double expectedDrawX, double expectedDrawY,
      double expectedDrawWidth, double expectedDrawHeight
  ) {
    doCheck(
        originalWidth, originalHeight, maxWidth, maxHeight, crop,
        expectedWidth, expectedHeight, expectedScale,
        expectedDrawX, expectedDrawY, expectedDrawWidth, expectedDrawHeight
    );
    doCheck(
        originalHeight, originalWidth, maxHeight, maxWidth, crop,
        expectedHeight, expectedWidth, expectedScale,
        expectedDrawY, expectedDrawX, expectedDrawHeight, expectedDrawWidth
    );
  }

  private void check(
      int originalWidth, int originalHeight,
      Double maxWidth, Double maxHeight,
      int expectedWidth, int expectedHeight,
      double expectedScale,
      double expectedDrawX, double expectedDrawY,
      double expectedDrawWidth, double expectedDrawHeight
  ) {
    check(
        originalWidth, originalHeight, maxWidth, maxHeight, false,
        expectedWidth, expectedHeight, expectedScale,
        expectedDrawX, expectedDrawY, expectedDrawWidth, expectedDrawHeight
    );
    check(
        originalWidth, originalHeight, maxWidth, maxHeight, true,
        expectedWidth, expectedHeight, expectedScale,
        expectedDrawX, expectedDrawY, expectedDrawWidth, expectedDrawHeight
    );
  }

  @Test
  public void testEmpty() {
    check(
        0, 0, null, null,
        0, 0, 1,
        0, 0, 0, 0
    );
    check(
        50, 0, null, null,
        50, 0, 1,
        0, 0, 50, 0
    );
    check(
        0, 0, 50.0, null,
        0, 0, 1,
        0, 0, 0, 0
    );
    check(
        100, 0, 50.0, null,
        50, 0, 0.5,
        0, 0, 50, 0
    );
  }

  @Test
  public void testNoLimits() {
    check(
        200, 300, null, null,
        200, 300, 1,
        0, 0, 200, 300
    );
  }

  @Test
  public void testOnlyWidth() {
    check(
        200, 300, 220.0, null,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, 200.0, null,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, 100.0, null,
        100, 150, 0.5,
        0, 0, 100, 150
    );
  }

  @Test
  public void testOnlyHeight() {
    check(
        200, 300, null, 320.0,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, null, 300.0,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, null, 100.0,
        67, 100, 1.0 / 3.0,
        0, 0, 67, 100
    );
  }

  @Test
  public void testLoose() {
    check(
        200, 300, 220.0, 320.0,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, 200.0, 320.0,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, 220.0, 300.0,
        200, 300, 1,
        0, 0, 200, 300
    );
    check(
        200, 300, 200.0, 300.0,
        200, 300, 1,
        0, 0, 200, 300
    );
  }

  @Test
  public void testFit() {
    check(
        200, 300, 200.0, 250.0, false,
        167, 250, 5.0 / 6.0,
        0, 0, 167, 250
    );
    check(
        200, 300, 100.0, 250.0, false,
        100, 150, 0.5,
        0, 0, 100, 150
    );
    check(
        200, 300, 150.0, 100.0, false,
        67, 100, 1.0 / 3.0,
        0, 0, 67, 100
    );
  }

  @Test
  public void testCrop() {
    check(
        200, 300, 200.0, 250.0, true,
        200, 250, 1,
        0, -25, 200, 300
    );
    check(
        200, 300, 100.0, 250.0, true,
        100, 250, 5.0 / 6.0,
        -33.5, 0, 167, 250
    );
    check(
        200, 300, 150.0, 100.0, true,
        150, 100, 3.0 / 4.0,
        0, -62.5, 150, 225
    );
  }
}

