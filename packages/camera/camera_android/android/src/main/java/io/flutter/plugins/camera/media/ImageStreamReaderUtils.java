// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Note: the code in this file is taken directly from the official Google MLKit example:
// https://github.com/googlesamples/mlkit

package io.flutter.plugins.camera.media;

import android.media.Image;
import androidx.annotation.NonNull;
import java.nio.ByteBuffer;

public class ImageStreamReaderUtils {
  /**
   * Converts YUV_420_888 to NV21 bytebuffer.
   *
   * <p>The NV21 format consists of a single byte array containing the Y, U and V values. For an
   * image of size S, the first S positions of the array contain all the Y values. The remaining
   * positions contain interleaved V and U values. U and V are subsampled by a factor of 2 in both
   * dimensions, so there are S/4 U values and S/4 V values. In summary, the NV21 array will contain
   * S Y values followed by S/4 VU values: YYYYYYYYYYYYYY(...)YVUVUVUVU(...)VU
   *
   * <p>YUV_420_888 is a generic format that can describe any YUV image where U and V are subsampled
   * by a factor of 2 in both dimensions. {@link Image#getPlanes} returns an array with the Y, U and
   * V planes. The Y plane is guaranteed not to be interleaved, so we can just copy its values into
   * the first part of the NV21 array. The U and V planes may already have the representation in the
   * NV21 format. This happens if the planes share the same buffer, the V buffer is one position
   * before the U buffer and the planes have a pixelStride of 2. If this is case, we can just copy
   * them to the NV21 array.
   *
   * <p>https://github.com/googlesamples/mlkit/blob/master/android/vision-quickstart/app/src/main/java/com/google/mlkit/vision/demo/BitmapUtils.java
   */
  public ByteBuffer yuv420ThreePlanesToNV21(Image.Plane[] yuv420888planes, int width, int height) {
    int imageSize = width * height;
    byte[] out = new byte[imageSize + 2 * (imageSize / 4)];

    if (areUVPlanesNV21(yuv420888planes, width, height)) {
      //      Log.i("flutter", "planes are NV21");

      // Copy the Y values.
      yuv420888planes[0].getBuffer().get(out, 0, imageSize);

      ByteBuffer uBuffer = yuv420888planes[1].getBuffer();
      ByteBuffer vBuffer = yuv420888planes[2].getBuffer();
      // Get the first V value from the V buffer, since the U buffer does not contain it.
      vBuffer.get(out, imageSize, 1);
      // Copy the first U value and the remaining VU values from the U buffer.
      uBuffer.get(out, imageSize + 1, 2 * imageSize / 4 - 1);
    } else {
      //      Log.i("flutter", "planes are not NV21");

      // Fallback to copying the UV values one by one, which is slower but also works.
      // Unpack Y.
      unpackPlane(yuv420888planes[0], width, height, out, 0, 1);
      // Unpack U.
      unpackPlane(yuv420888planes[1], width, height, out, imageSize + 1, 2);
      // Unpack V.
      unpackPlane(yuv420888planes[2], width, height, out, imageSize, 2);
    }

    return ByteBuffer.wrap(out);
  }

  /**
   * Copyright 2020 Google LLC. All rights reserved.
   *
   * <p>Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
   * except in compliance with the License. You may obtain a copy of the License at
   *
   * <p>http://www.apache.org/licenses/LICENSE-2.0
   *
   * <p>Unless required by applicable law or agreed to in writing, software distributed under the
   * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
   * either express or implied. See the License for the specific language governing permissions and
   * limitations under the License.
   *
   * <p>Checks if the UV plane buffers of a YUV_420_888 image are in the NV21 format.
   *
   * <p>https://github.com/googlesamples/mlkit/blob/master/android/vision-quickstart/app/src/main/java/com/google/mlkit/vision/demo/BitmapUtils.java
   */
  private static boolean areUVPlanesNV21(@NonNull Image.Plane[] planes, int width, int height) {
    int imageSize = width * height;

    ByteBuffer uBuffer = planes[1].getBuffer();
    ByteBuffer vBuffer = planes[2].getBuffer();

    // Backup buffer properties.
    int vBufferPosition = vBuffer.position();
    int uBufferLimit = uBuffer.limit();

    // Advance the V buffer by 1 byte, since the U buffer will not contain the first V value.
    vBuffer.position(vBufferPosition + 1);
    // Chop off the last byte of the U buffer, since the V buffer will not contain the last U value.
    uBuffer.limit(uBufferLimit - 1);

    // Check that the buffers are equal and have the expected number of elements.
    boolean areNV21 =
        (vBuffer.remaining() == (2 * imageSize / 4 - 2)) && (vBuffer.compareTo(uBuffer) == 0);

    // Restore buffers to their initial state.
    vBuffer.position(vBufferPosition);
    uBuffer.limit(uBufferLimit);

    return areNV21;
  }

  /**
   * Copyright 2020 Google LLC. All rights reserved.
   *
   * <p>Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
   * except in compliance with the License. You may obtain a copy of the License at
   *
   * <p>http://www.apache.org/licenses/LICENSE-2.0
   *
   * <p>Unless required by applicable law or agreed to in writing, software distributed under the
   * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
   * either express or implied. See the License for the specific language governing permissions and
   * limitations under the License.
   *
   * <p>Unpack an image plane into a byte array.
   *
   * <p>The input plane data will be copied in 'out', starting at 'offset' and every pixel will be
   * spaced by 'pixelStride'. Note that there is no row padding on the output.
   *
   * <p>https://github.com/googlesamples/mlkit/blob/master/android/vision-quickstart/app/src/main/java/com/google/mlkit/vision/demo/BitmapUtils.java
   */
  private static void unpackPlane(
      @NonNull Image.Plane plane, int width, int height, byte[] out, int offset, int pixelStride)
      throws IllegalStateException {
    ByteBuffer buffer = plane.getBuffer();
    buffer.rewind();

    // Compute the size of the current plane.
    // We assume that it has the aspect ratio as the original image.
    int numRow = (buffer.limit() + plane.getRowStride() - 1) / plane.getRowStride();
    if (numRow == 0) {
      return;
    }
    int scaleFactor = height / numRow;
    int numCol = width / scaleFactor;

    // Extract the data in the output buffer.
    int outputPos = offset;
    int rowStart = 0;
    for (int row = 0; row < numRow; row++) {
      int inputPos = rowStart;
      for (int col = 0; col < numCol; col++) {
        out[outputPos] = buffer.get(inputPos);
        outputPos += pixelStride;
        inputPos += plane.getPixelStride();
      }
      rowStart += plane.getRowStride();
    }
  }
}
