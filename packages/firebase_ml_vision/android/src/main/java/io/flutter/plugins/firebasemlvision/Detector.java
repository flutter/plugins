package io.flutter.plugins.firebasemlvision;

import android.support.annotation.Nullable;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

interface Detector {
  void handleDetection(FirebaseVisionImage image, @Nullable Map<String, Object> options, final MethodChannel.Result result);
}
