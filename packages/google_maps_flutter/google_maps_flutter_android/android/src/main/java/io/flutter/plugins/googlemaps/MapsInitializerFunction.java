package io.flutter.plugins.googlemaps;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;

@FunctionalInterface
public interface MapsInitializerFunction {
  int initialize(
      @NonNull Context context,
      @Nullable MapsInitializer.Renderer preferredRenderer,
      @Nullable OnMapsSdkInitializedCallback callback);
}
