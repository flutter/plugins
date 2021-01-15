package io.flutter.plugins.googlemaps;

import static junit.framework.TestCase.assertEquals;

import com.google.android.gms.maps.model.PolygonOptions;
import org.junit.Test;

public class PolygonBuilderTest {

  @Test
  public void density_AppliesToStrokeWidth() {
    final float density = 5;
    final float strokeWidth = 3;

    final PolygonBuilder builder = new PolygonBuilder(density);
    builder.setStrokeWidth(strokeWidth);

    final PolygonOptions options = builder.build();
    final float width = options.getStrokeWidth();

    assertEquals(density * strokeWidth, width);
  }
}
