package io.flutter.plugins.googlemaps;

import static io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
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
  public PlatformView create(Context context, int id, Object params) {
    final GoogleMapBuilder builder = new GoogleMapBuilder();
    Convert.interpretGoogleMapOptions(params, builder);
    return builder.build(id, context, mActivityState, mPluginRegistrar);
  }
}
