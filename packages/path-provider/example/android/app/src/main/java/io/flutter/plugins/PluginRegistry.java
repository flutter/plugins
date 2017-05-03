package io.flutter.plugins;

import io.flutter.app.FlutterActivity;

import io.flutter.plugins.path_provider.PathProviderPlugin;

/**
 * Generated file. Do not edit.
 */

public class PluginRegistry {
    public PathProviderPlugin path_provider;

    public void registerAll(FlutterActivity activity) {
        path_provider = PathProviderPlugin.register(activity);
    }
}
