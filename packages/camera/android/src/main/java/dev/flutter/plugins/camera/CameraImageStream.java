package dev.flutter.plugins.camera;

import android.media.Image;

import androidx.annotation.NonNull;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class CameraImageStream {
  private final EventChannel.EventSink imageStreamSink;

  CameraImageStream(@NonNull EventChannel.EventSink imageStreamSink) {
    this.imageStreamSink = imageStreamSink;
  }

  public void sendImage(@NonNull Image image) {
    List<Map<String, Object>> planes = new ArrayList<>();
    for (Image.Plane plane : image.getPlanes()) {
      ByteBuffer buffer = plane.getBuffer();

      byte[] bytes = new byte[buffer.remaining()];
      buffer.get(bytes, 0, bytes.length);

      Map<String, Object> planeBuffer = new HashMap<>();
      planeBuffer.put("bytesPerRow", plane.getRowStride());
      planeBuffer.put("bytesPerPixel", plane.getPixelStride());
      planeBuffer.put("bytes", bytes);

      planes.add(planeBuffer);
    }

    Map<String, Object> imageBuffer = new HashMap<>();
    imageBuffer.put("width", image.getWidth());
    imageBuffer.put("height", image.getHeight());
    imageBuffer.put("format", image.getFormat());
    imageBuffer.put("planes", planes);

    imageStreamSink.success(imageBuffer);
  }
}
