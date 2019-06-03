package io.flutter.plugins.firebase_mlkit_language;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

/** FirebaseMlkitLanguagePlugin */
public class FirebaseMlkitLanguagePlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "firebase_mlkit_language");
    channel.setMethodCallHandler(new FirebaseMlkitLanguagePlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String modelname = call.argument("model");
    String text = call.argument("text");
    Map<String, Object> options = call.argument("options");
    switch (call.method) {
      case "LanguageIdentifier#processText":
        LanguageIdentifier.instance.handleEvent(text, options, result);
        break;
      case "LanguageTranslator#processText":
        LanguageTranslator.instance.handleEvent(text, options, result);
        break;
      case "ModelManager#viewModels":
        ViewModels.instance.handleEvent(result);
        break;
      case "ModelManager#deleteModel":
        DeleteModel.instance.handleEvent(modelname, result);
        break;
      case "ModelManager#downloadModel":
        DownloadModel.instance.handleEvent(modelname, result);
        break;
      default:
        result.notImplemented();
    }
  }
}
