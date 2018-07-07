import 'package:firebase_ml_vision_example/detector_painters.dart';
import 'package:flutter/material.dart';

class LivePreview extends StatelessWidget {
  final Detector detector;

  const LivePreview(this.detector, {Key key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Current detector: $detector"),
    );
  }
}
