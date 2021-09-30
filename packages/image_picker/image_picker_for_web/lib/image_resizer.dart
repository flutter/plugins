import 'dart:async';
import 'dart:ui';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'dart:html' as html;


/// Resizes images
class ImageResizer {
  /// Resizes images if needed
  Future<XFile> resizeImageIfNeeded(XFile file, double? maxWidth,
      double? maxHeight, int? imageQuality) async {
    if (maxWidth == null && maxHeight == null && imageQuality == null ||
        file.mimeType == "image/gif") {
      return file;
    }
    final imageLoadCompleter = Completer();
    final imageElement = html.ImageElement();
    imageElement.src = file.path;
    imageElement.onLoad.listen((event) {
      html.Url.revokeObjectUrl(file.path);
      imageLoadCompleter.complete();
    });

    //Return the original image if error comes
    imageElement.onError.listen((event) {
      imageLoadCompleter.complete();
    });
    await imageLoadCompleter.future;

    final newImageSize = calculateSize(
        imageElement.width!.toDouble(), imageElement.height!.toDouble(),
        maxWidth ?? imageElement.width!.toDouble(),
        maxHeight ?? imageElement.height!.toDouble());
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
    final blob = await canvas.toBlob(
        file.mimeType,
        (imageQuality ?? 100) /
            100.0); // Image quality only works for jpeg images
    return XFile(
        html.Url.createObjectUrlFromBlob(blob),
        mimeType: file.mimeType,
        name: file.name,
        lastModified: DateTime.now(),
        length: blob.size
    );
  }


  /// Calculates the size of the scaled image.
  Size calculateSize(double imageWidth, double imageHeight, double maxWidth,
      double maxHeight) {
    var width = imageWidth;
    var height = imageHeight;
    var scaledHeight = height;
    var scaledWidth = width;
    if (width > height) {
      if (width > maxWidth) {
        scaledHeight = ((height * maxWidth) / width);
      }
    } else {
      if (height > maxHeight) {
        scaledWidth = ((width * maxHeight) / height);
      }
    }
    return Size(scaledWidth, scaledHeight);
  }
}
