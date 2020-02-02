package io.flutter.plugins.google_sign_in_web;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** GoogleSignInWebPlugin */
public class GoogleSignInWebPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {}

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {}

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
