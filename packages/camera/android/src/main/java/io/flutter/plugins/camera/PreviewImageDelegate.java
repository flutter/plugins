package io.flutter.plugins.camera;

import android.media.Image;

public interface PreviewImageDelegate {
  void onImageAvailable(Image image, int rotation);
}
