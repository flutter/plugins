package io.flutter.plugins.firebase.firebaseremoteconfig;

import com.google.firebase.BuildConfig;
import com.google.firebase.components.Component;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.platforminfo.LibraryVersionComponent;

import java.util.Collections;
import java.util.List;

public class FlutterFirebaseAppRegistrar implements ComponentRegistrar {
  private static final String LIBRARY_NAME = "flutter-fire-rc";

  @Override
  public List<Component<?>> getComponents() {
    return Collections.<Component<?>>singletonList(
        LibraryVersionComponent.create(LIBRARY_NAME, BuildConfig.VERSION_NAME));
  }
}
