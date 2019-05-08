package io.flutter.plugins.firebase.core;

import com.google.firebase.components.Component;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.platforminfo.LibraryVersionComponent;

import java.util.Collections;
import java.util.List;

public class FlutterFireAppRegistrar implements ComponentRegistrar {
    @Override
    public List<Component<?>> getComponents() {
        return Collections.<Component<?>>singletonList(
                LibraryVersionComponent.create(
                        "flutter-firebase_core",
                        "0.4.1"
                )
        );
    }
}