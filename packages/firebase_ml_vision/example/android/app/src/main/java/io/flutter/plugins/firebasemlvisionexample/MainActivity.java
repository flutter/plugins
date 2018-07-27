package io.flutter.plugins.firebasemlvisionexample;

import android.media.Image;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.camera.PreviewImageDelegate;
import io.flutter.plugins.firebasemlvision.live.CameraPreviewImageProvider;

public class MainActivity extends FlutterActivity implements PreviewImageDelegate, CameraPreviewImageProvider {
  @Nullable
  private PreviewImageDelegate previewImageDelegate;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  public void onImageAvailable(Image image, int rotation) {
    if (previewImageDelegate != null) {
      previewImageDelegate.onImageAvailable(image, rotation);
    }
  }

  @Override
  public void setImageDelegate(PreviewImageDelegate delegate) {
    previewImageDelegate = delegate;
  }
}
