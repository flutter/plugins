part of support_android_camera;

enum Facing { back, front }

class CameraInfo implements CameraDescription {
  const CameraInfo._({
    @required this.id,
    @required this.facing,
    @required this.orientation,
  })  : assert(id != null),
        assert(facing != null),
        assert(orientation != null);

  factory CameraInfo._fromMap(Map<String, dynamic> map) {
    return CameraInfo._(
      id: map['id'],
      orientation: map['orientation'],
      facing: Facing.values.firstWhere(
        (Facing facing) => facing.toString() == map['facing'],
      ),
    );
  }

  final int id;
  final Facing facing;
  final int orientation;

  @override
  String get name => id.toString();

  @override
  LensDirection get direction {
    switch (facing) {
      case Facing.front:
        return LensDirection.front;
      case Facing.back:
        return LensDirection.back;
    }

    return null;
  }
}
