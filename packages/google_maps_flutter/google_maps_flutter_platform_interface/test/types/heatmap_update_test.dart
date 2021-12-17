import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$HeatmapUpdates', () {
    test('heatmap updates default constructor', () {
      final heatmapUpdates = HeatmapUpdates.from(Set(), Set());

      expect(heatmapUpdates.heatmapsToAdd, equals(Set<Heatmap>.identity()));
      expect(
          heatmapUpdates.heatmapIdsToRemove, equals(Set<Heatmap>.identity()));
      expect(heatmapUpdates.heatmapsToChange, equals(Set<Heatmap>.identity()));
    });
    test('heatmap updates with map to add', () {
      final newHeatmaps = Set<Heatmap>.from([
        Heatmap(
          heatmapId: HeatmapId("test1"),
          gradient: HeatmapGradient(
              colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
              startPoints: [0.25, 0.75]),
          points: [WeightedLatLng(point: LatLng(1, 1), intensity: 20)],
        )
      ]);
      final heatmapUpdates = HeatmapUpdates.from(Set(), newHeatmaps);

      expect(heatmapUpdates.heatmapsToAdd, equals(newHeatmaps));
      expect(
          heatmapUpdates.heatmapIdsToRemove, equals(Set<Heatmap>.identity()));
      expect(heatmapUpdates.heatmapsToChange, equals(Set<Heatmap>.identity()));
    });
    test('heatmap updates with map to remove', () {
      final heatmaps = Set<Heatmap>.from([
        Heatmap(
          heatmapId: HeatmapId("test1"),
          gradient: HeatmapGradient(
              colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
              startPoints: [0.25, 0.75]),
          points: [WeightedLatLng(point: LatLng(1, 1), intensity: 20)],
        )
      ]);
      final heatmapUpdates = HeatmapUpdates.from(heatmaps, Set());

      expect(heatmapUpdates.heatmapsToAdd, equals(Set<Heatmap>.identity()));
      expect(heatmapUpdates.heatmapIdsToRemove.first,
          equals(heatmaps.first.heatmapId));
      expect(heatmapUpdates.heatmapsToChange, equals(Set<Heatmap>.identity()));
    });
    test('heatmap updates with map to change', () {
      final heatmapOriginal = Heatmap(
        heatmapId: HeatmapId("test1"),
        gradient: HeatmapGradient(
            colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
            startPoints: [0.25, 0.75]),
        points: [WeightedLatLng(point: LatLng(1, 1), intensity: 20)],
      );
      final heatmapChanged = heatmapOriginal.clone();
      heatmapChanged.points.first =
          WeightedLatLng(point: LatLng(1, 1), intensity: 40);
      final heatmapUpdates = HeatmapUpdates.from(
          Set<Heatmap>.from([heatmapOriginal]),
          Set<Heatmap>.from([heatmapChanged]));

      expect(heatmapUpdates.heatmapsToAdd, equals(Set<Heatmap>.identity()));
      expect(heatmapUpdates.heatmapsToAdd, equals(Set<Heatmap>.identity()));
      expect(heatmapUpdates.heatmapsToChange.first.heatmapId,
          equals(HeatmapId("test1")));
    });
  });
}
