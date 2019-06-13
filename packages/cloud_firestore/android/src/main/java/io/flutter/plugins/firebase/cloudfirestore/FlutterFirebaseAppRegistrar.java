package io.flutter.plugins.firebase.cloudfirestore;

import com.google.firebase.components.Component;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.platforminfo.LibraryVersionComponent;
import java.util.Collections;
import java.util.List;

import io.flutter.plugins.firebase.firestore.BuildConfig;

public class FlutterFirebaseAppRegistrar implements ComponentRegistrar {
  private static final String LIBRARY_NAME = "flutter-fire-fst";

  @Override
  public List<Component<?>> getComponents() {
    return Collections.<Component<?>>singletonList(
        LibraryVersionComponent.create(LIBRARY_NAME, BuildConfig.VERSION_NAME));
  }
}
