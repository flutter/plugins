part of google_maps_flutter;

/// Joint types for Polyline.
class JointType {
  const JointType._();

  /// Mitered joint, with fixed pointed extrusion equal to half the stroke width on the outside of the joint.
  ///
  /// Contant Value: 0
  static const int mitered = 0;

  /// Flat bevel on the outside of the joint.
  ///
  /// Contant Value: 1
  static const int bevel = 1;

  /// Rounded on the outside of the joint by an arc of radius equal to half the stroke width, centered at the vertex.
  ///
  /// /// Contant Value: 2
  static const int round = 2;
}
