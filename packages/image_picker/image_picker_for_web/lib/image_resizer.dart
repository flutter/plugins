import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'dart:html' as html;

/// Resizes images
class ImageResizer {
  /// Resizes the image if needed
  /// Does not support gif image
  Future<XFile> resizeImageIfNeeded(XFile file, double? maxWidth,
      double? maxHeight, int? imageQuality) async {
    if ((maxWidth == null &&
        maxHeight == null
    ) || !_isImageQualityValid(imageQuality) ||
        file.mimeType == "image/gif") {
      //TODO Implement maxWidth and maxHeight for image/gif
      return file;
    }
    final imageLoadCompleter = Completer();
    final imageElement = html.ImageElement();
    imageElement.src = file.path;
    imageElement.onLoad.listen((event) {
      html.Url.revokeObjectUrl(file.path);
      imageLoadCompleter.complete();
    });

    await imageLoadCompleter.future;

    final newImageSize = calculateSize(imageElement.width!.toDouble(),
        imageElement.height!.toDouble(), maxWidth, maxHeight);
    final canvas = html.CanvasElement();
    canvas.width = newImageSize.width.toInt();
    canvas.height = newImageSize.height.toInt();
    final context = canvas.context2D;
    if (maxHeight == null && maxWidth == null) {
      context.drawImage(imageElement, 0, 0);
    } else {
      context.drawImageScaled(
          imageElement, 0, 0, canvas.width!, canvas.height!);
    }
    final calculatedImageQuality = ((min(imageQuality ?? 100, 100)) /
        100.0);
    final blob = await canvas.toBlob(
        file.mimeType,
        calculatedImageQuality); // Image quality only works for jpeg and webp images
    return XFile(html.Url.createObjectUrlFromBlob(blob),
        mimeType: file.mimeType,
        name: file.name,
        lastModified: DateTime.now(),
        length: blob.size);
  }

  /// Calculates the size of the scaled image from [maxWidth] and [maxHeigth.
  Size calculateSize(double imageWidth, double imageHeight, double? maxWidth,
      double? maxHeight) {
    double originalWidth = imageWidth;
    double originalHeight = imageHeight;

    bool hasMaxWidth = maxWidth != null;
    bool hasMaxHeight = maxHeight != null;
    double width = hasMaxWidth ? min(maxWidth, originalWidth) : originalWidth;
    double height =
    hasMaxHeight ? min(maxHeight, originalHeight) : originalHeight;
    bool shouldDownscaleWidth = hasMaxWidth && maxWidth < originalWidth;
    bool shouldDownscaleHeight = hasMaxHeight && maxHeight < originalHeight;
    bool shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;
    if (shouldDownscale) {
      double downscaledWidth =
      ((height / originalHeight) * originalWidth).floorToDouble();
      double downscaledHeight =
      ((width / originalWidth) * originalHeight).floorToDouble();

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
    if (hasMaxHeight) {
      assert(height <= maxHeight);
    }
    if (hasMaxWidth) {
      assert(width <= maxWidth);
    }
    return Size(width, height);
  }

  bool _isImageQualityValid(int? imageQuality) {
    return imageQuality == null || (imageQuality >= 0 && imageQuality <= 100);
  }
}
