import 'picked_file/picked_file.dart';

/// A PickedImage is a [PickedFile] with an optional [thumbnail] variable for
/// a small sized thumbnail image file.
class PickedImage extends PickedFile {

  /// Small sized thumbnail image file
  final PickedFile thumbnail;

  /// Constructs a PickedImage object from the imagePath with optionally the
  /// path to a thumbnail file.
  PickedImage(String imagePath, {String thumbnailPath}) :
      thumbnail = thumbnailPath != null ? PickedFile(thumbnailPath) : null,
      super(imagePath);
}
