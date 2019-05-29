package io.flutter.plugins.firebase.cloudfirestore;

import com.google.firebase.components.Component;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.platforminfo.LibraryVersionComponent;
import java.util.Collections;
import java.util.List;

public class FlutterFirebaseAppRegistrar implements ComponentRegistrar {
  private static final String LIBRARY_NAME = "flutter-firebase_cloud_firestore";
  private static final String LIBRARY_VERSION = "0.12.0+1";

  @Override
  public List<Component<?>> getComponents() {
    return Collections.<Component<?>>singletonList(
        LibraryVersionComponent.create(LIBRARY_NAME, LIBRARY_VERSION));
  }
}
