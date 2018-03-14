package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.esafirm.imagepicker.model.Image;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageResizer {
    File resizedImage(Image image, Double maxWidth, Double maxHeight) throws IOException {
        Bitmap bmp = BitmapFactory.decodeFile(image.getPath());
        double originalWidth = bmp.getWidth() * 1.0;
        double originalHeight = bmp.getHeight() * 1.0;

        boolean hasMaxWidth = maxWidth != null;
        boolean hasMaxHeight = maxHeight != null;

        Double width = hasMaxWidth ? Math.min(originalWidth, maxWidth) : originalWidth;
        Double height = hasMaxHeight ? Math.min(originalHeight, maxHeight) : originalHeight;

        boolean shouldDownscaleWidth = hasMaxWidth && maxWidth < originalWidth;
        boolean shouldDownscaleHeight = hasMaxHeight && maxHeight < originalHeight;
        boolean shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;

        if (shouldDownscale) {
            double downscaledWidth = (height / originalHeight) * originalWidth;
            double downscaledHeight = (width / originalWidth) * originalHeight;

            if (width < height) {
                if (!hasMaxWidth) {
                    width = downscaledWidth;
                } else {
                    height = downscaledHeight;
                }
            } else if (height < width) {
                if (!hasMaxHeight) {
                    height = downscaledHeight;
                } else {
                    width = downscaledWidth;
                }
            } else {
                if (originalWidth < originalHeight) {
                    width = downscaledWidth;
                } else if (originalHeight < originalWidth) {
                    height = downscaledHeight;
                }
            }
        }

        Bitmap scaledBmp = Bitmap.createScaledBitmap(bmp, width.intValue(), height.intValue(), false);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        scaledBmp.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);

        String scaledCopyPath = image.getPath().replace(image.getName(), "scaled_" + image.getName());
        File imageFile = new File(scaledCopyPath);

        FileOutputStream fileOutput = new FileOutputStream(imageFile);
        fileOutput.write(outputStream.toByteArray());
        fileOutput.close();

        return imageFile;
    }
}
