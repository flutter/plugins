import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Heatmap', () {
    test('constructor defaults', () {
      final Heatmap heatmap = Heatmap(
        heatmapId: HeatmapId("test1"),
        gradient: HeatmapGradient(
            colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
            startPoints: [0.25, 0.75]),
      );

      expect(heatmap.heatmapId, equals(HeatmapId("test1")));
      expect(
          heatmap.gradient,
          equals(
            HeatmapGradient(
                colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
                startPoints: [0.25, 0.75]),
          ));
      expect(heatmap.points, equals([]));
      expect(heatmap.opacity, equals(0.7));
      expect(heatmap.radius, equals(20));
      expect(heatmap.fadeIn, isTrue);
      expect(heatmap.transparency, equals(0));
      expect(heatmap.visible, isTrue);
      expect(heatmap.zIndex, equals(0));
    });
    test('clone returns copy of heatmap', () {
      final Heatmap heatmap = Heatmap(
        heatmapId: HeatmapId("test1"),
        gradient: HeatmapGradient(
            colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
            startPoints: [0.25, 0.75]),
        points: [WeightedLatLng(point: LatLng(1, 1), intensity: 20)],
      );

      final cloneHeatmap = heatmap.clone();

      // Check the objects are qualitatively equal
      expect(heatmap, equals(cloneHeatmap));

      // Check it actually created a new object
      expect(
          identityHashCode(heatmap) == identityHashCode(cloneHeatmap), isFalse);
    });
  });
}
