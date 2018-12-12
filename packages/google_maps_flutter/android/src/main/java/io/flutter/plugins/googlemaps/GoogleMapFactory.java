package io.flutter.plugins.googlemaps;

import static io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import com.google.android.gms.maps.model.CameraPosition;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class GoogleMapFactory extends PlatformViewFactory {

  private final AtomicInteger mActivityState;
  private final Registrar mPluginRegistrar;

  public GoogleMapFactory(AtomicInteger state, Registrar registrar) {
    super(StandardMessageCodec.INSTANCE);
    mActivityState = state;
    mPluginRegistrar = registrar;
  }

  @Override
  public PlatformView create(Context context, int id, Map<String, Object> args) {
    final GoogleMapBuilder builder = new GoogleMapBuilder();

    Convert.interpretGoogleMapOptions(args.get("options"), builder);
    if (args.containsKey("initialCameraPosition")) {
      CameraPosition position = Convert.toCameraPosition(args.get("initialCameraPosition"));
      builder.setInitialCameraPosition(position);
    }
    return builder.build(id, context, mActivityState, mPluginRegistrar);
  }
}
