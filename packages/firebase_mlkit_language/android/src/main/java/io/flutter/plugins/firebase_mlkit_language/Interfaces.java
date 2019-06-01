package io.flutter.plugins.firebase_mlkit_language;

import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

interface LanguageAgent {
  void handleEvent(String text, Map<String, Object> options, final MethodChannel.Result result);
}

interface ModelAgent {
  void handleEvent(String modelName, final MethodChannel.Result result);
}

interface ViewModelAgent {
  void handleEvent(final MethodChannel.Result result);
}
