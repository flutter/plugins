package io.flutter.plugins.googlemaps;

import static junit.framework.TestCase.assertEquals;

import com.google.android.gms.maps.model.PolylineOptions;
import org.junit.Test;

public class PolylineBuilderTest {

  @Test
  public void density_AppliesToStrokeWidth() {
    final float density = 5;
    final float strokeWidth = 3;

    final PolylineBuilder builder = new PolylineBuilder(density);
    builder.setWidth(strokeWidth);

    final PolylineOptions options = builder.build();
    final float width = options.getWidth();

    assertEquals(density * strokeWidth, width);
  }
}
