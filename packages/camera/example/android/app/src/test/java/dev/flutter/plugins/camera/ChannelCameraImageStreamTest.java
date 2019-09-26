package dev.flutter.plugins.camera;

import android.media.Image;

import androidx.annotation.NonNull;

import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class ChannelCameraImageStreamTest {

  @Test
  public void itSerializesImageAndSendsThroughChannel() {
    // Setup test.
    // One row of pixels, with 1 byte per pixel.
    final byte[] fakeImageBytes = new byte[] {
        0b00000001,
        0b00000010,
        0b00000011,
        0b00000100,
        0b00000101,
        0b00000110,
        0b00000111,
        0b00001000,
        0b00001001,
        0b00001010
    };

    // Create a fake Image. Most numbers don't matter, but
    // each plane's bytesPerRow and bytesPerPixel must be
    // congruent with the corresponding fake bytes.
    final Image fakeImage = new FakeImageBuilder()
        .width(1920)
        .height(1080)
        .format(1)
        .buildPlane()
          .bytesPerRow(10)
          .bytesPerPixel(1)
          .bytes(fakeImageBytes)
          .build()
        .build();

    final EventChannel.EventSink fakeEventSink = mock(EventChannel.EventSink.class);
    final CameraPluginProtocol.ChannelCameraImageStream imageStream = new CameraPluginProtocol.ChannelCameraImageStream(fakeEventSink);

    // Execute the behavior under test.
    imageStream.sendImage(fakeImage);

    // Verify results.
    // Verify that the channel was invoked, and capture the response.
    ArgumentCaptor<Map> responseCaptor = ArgumentCaptor.forClass(Map.class);
    verify(fakeEventSink, times(1)).success(responseCaptor.capture());
    Map<String, Object> response = (Map<String, Object>) responseCaptor.getValue();

    // Verify the reported width, height, and format of the Image.
    assertEquals(1920, response.get("width"));
    assertEquals(1080, response.get("height"));
    assertEquals(1, response.get("format"));

    // Verify the reported Plane's bytes per row and bytes per pixel.
    List<Map<String, Object>> serializedPlanes = (List<Map<String, Object>>) response.get("planes");
    assertEquals(1, serializedPlanes.size());
    Map<String, Object> serializedPlane = serializedPlanes.get(0);
    assertEquals(10, serializedPlane.get("bytesPerRow"));
    assertEquals(1, serializedPlane.get("bytesPerPixel"));

    // Verify the reported Plane's bytes value.
    byte[] serializedBytes = (byte[]) serializedPlane.get("bytes");
    assertArrayEquals(fakeImageBytes, serializedBytes);
  }

  /**
   * Builds a fake {@link Image} with desired properties.
   */
  private static class FakeImageBuilder {
    private int width;
    private int height;
    private int format;
    private final List<Image.Plane> fakePlanes = new ArrayList<>();

    @NonNull
    public FakeImageBuilder width(int width) {
      this.width = width;
      return this;
    }

    @NonNull
    public FakeImageBuilder height(int height) {
      this.height = height;
      return this;
    }

    @NonNull
    public FakeImageBuilder format(int format) {
      this.format = format;
      return this;
    }

    @NonNull
    public FakeImagePlaneBuilder buildPlane() {
      return new FakeImagePlaneBuilder(this);
    }

    private void addPlane(@NonNull Image.Plane fakePlane) {
      fakePlanes.add(fakePlane);
    }

    @NonNull
    public Image build() {
      Image fakeImage = mock(Image.class);
      when(fakeImage.getWidth()).thenReturn(width);
      when(fakeImage.getHeight()).thenReturn(height);
      when(fakeImage.getFormat()).thenReturn(format);
      when(fakeImage.getPlanes()).thenReturn(fakePlanes.toArray(new Image.Plane[] {}));
      return fakeImage;
    }
  }

  /**
   * Builds a fake {@link Image.Plane} to go within a fake {@link Image}
   * as produced by a given {@link FakeImagePlaneBuilder}.
   */
  private static class FakeImagePlaneBuilder {
    private final FakeImageBuilder imageBuilder;
    private int bytesPerRow;
    private int bytesPerPixel;
    private byte[] bytes;

    private FakeImagePlaneBuilder(@NonNull FakeImageBuilder imageBuilder) {
      this.imageBuilder = imageBuilder;
    }

    @NonNull
    public FakeImagePlaneBuilder bytesPerRow(int count) {
      this.bytesPerRow = count;
      return this;
    }

    @NonNull
    public FakeImagePlaneBuilder bytesPerPixel(int count) {
      this.bytesPerPixel = count;
      return this;
    }

    @NonNull
    public FakeImagePlaneBuilder bytes(@NonNull byte[] bytes) {
      this.bytes = bytes;
      return this;
    }

    @NonNull
    public FakeImageBuilder build() {
      Image.Plane fakePlane = mock(Image.Plane.class);
      when(fakePlane.getRowStride()).thenReturn(bytesPerRow);
      when(fakePlane.getPixelStride()).thenReturn(bytesPerPixel);

      final int byteCount = bytesPerRow * bytesPerPixel;
      assertEquals(
          "Provided bytes must match expected byte count: row * pixel",
          byteCount,
          bytes.length
      );

      ByteBuffer buffer = mock(ByteBuffer.class);
      when(buffer.remaining()).thenReturn(byteCount);
      when(buffer.get(any(byte[].class), eq(0), eq(byteCount))).thenAnswer(new Answer<Void>() {
        @Override
        public Void answer(InvocationOnMock invocation) throws Throwable {
          byte[] outputBytes = invocation.getArgument(0);
          assertEquals(
              "The array that is receiving bytes must be the same size as the fake array of bytes.",
              bytes.length,
              outputBytes.length
          );
          for (int i = 0; i < bytes.length; ++i) {
            outputBytes[i] = bytes[i];
          }
          return null;
        }
      });
      when(fakePlane.getBuffer()).thenReturn(buffer);

      imageBuilder.addPlane(fakePlane);

      return imageBuilder;
    }
  }

}
