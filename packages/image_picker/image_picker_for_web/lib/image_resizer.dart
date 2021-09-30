import 'dart:async';
import 'dart:math';
import 'package:image_picker_for_web/image_resizer_utils.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'dart:html' as html;

/// Resizes images
class ImageResizer {
  /// Resizes the image if needed
  /// Does not support gif image
  ///
  Future<XFile> resizeImageIfNeeded(XFile file, double? maxWidth,
      double? maxHeight, int? imageQuality) async {
    if (!imageResizeNeeded(maxWidth, maxHeight, imageQuality) ||
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

    final newImageSize = calculateSizeOfScaledImage(
        imageElement.width!.toDouble(),
        imageElement.height!.toDouble(),
        maxWidth,
        maxHeight);
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
    final calculatedImageQuality = ((min(imageQuality ?? 100, 100)) / 100.0);
    final blob = await canvas.toBlob(file.mimeType,
        calculatedImageQuality); // Image quality only works for jpeg and webp images
    return XFile(html.Url.createObjectUrlFromBlob(blob),
        mimeType: file.mimeType,
        name: "scaled_" + file.name,
        lastModified: DateTime.now(),
        length: blob.size);
  }
}
