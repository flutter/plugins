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
    Log.d("ML", "MainActivity created");
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  public void onImageAvailable(Image image) {
    Log.d("ML", "got a preview image");
    if (previewImageDelegate != null) {
      Log.d("ML", "the delegate was not null, sending image to ml for processing");
      previewImageDelegate.onImageAvailable(image);
    }
  }

  @Override
  public void setImageDelegate(PreviewImageDelegate delegate) {
    Log.d("ML", "setting image delegate");
    previewImageDelegate = delegate;
  }
}
