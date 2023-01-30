import 'package:flutter/material.dart';
import '../../google_maps_flutter_platform_interface.dart';

void _addIfNonNull(Map<String, Object?> map, String fieldName, Object? value) {
  if (value != null) {
    map[fieldName] = value;
  }
}

/// Serialize [MapsObjectUpdates]
Object serializeMapsObjectUpdates<T extends MapsObject<T>>(
  MapsObjectUpdates<T> updates,
  Object Function(T) serialize,
) {
  final Map<String, Object> json = <String, Object>{};

  _addIfNonNull(
    json,
    '${updates.objectName}sToAdd',
    updates.objectsToAdd.map(serialize),
  );
  _addIfNonNull(
    json,
    '${updates.objectName}sToChange',
    updates.objectsToChange.map(serialize),
  );
  _addIfNonNull(
    json,
    '${updates.objectName}IdsToRemove',
    updates.objectIdsToRemove
        .map<String>((MapsObjectId<T> m) => m.value)
        .toList(),
  );

  return json;
}

/// Serialize [Heatmap]
Object serializeHeatmap(Heatmap heatmap) {
  final Map<String, Object> json = <String, Object>{};

  _addIfNonNull(json, 'heatmapId', heatmap.heatmapId.value);
  _addIfNonNull(
    json,
    'data',
    heatmap.data.map(serializeWeightedLatLng).toList(),
  );
  _addIfNonNull(json, 'dissipating', heatmap.dissipating);

  final HeatmapGradient? gradient = heatmap.gradient;
  if (gradient != null) {
    _addIfNonNull(json, 'gradient', serializeHeatmapGradient(gradient));
  }
  _addIfNonNull(json, 'maxIntensity', heatmap.maxIntensity);
  _addIfNonNull(json, 'opacity', heatmap.opacity);
  _addIfNonNull(json, 'radius', heatmap.radius);
  _addIfNonNull(json, 'minimumZoomIntensity', heatmap.minimumZoomIntensity);
  _addIfNonNull(json, 'maximumZoomIntensity', heatmap.maximumZoomIntensity);

  return json;
}

/// Serialize [WeightedLatLng]
Object serializeWeightedLatLng(WeightedLatLng wll) {
  return <Object>[serializeLatLng(wll.point), wll.weight];
}

/// Deserialize [WeightedLatLng]
WeightedLatLng? deserializeWeightedLatLng(Object? json) {
  if (json == null) {
    return null;
  }
  assert(json is List && json.length == 2);
  final List<dynamic> list = json as List<dynamic>;
  final LatLng latLng = deserializeLatLng(list[0])!;
  return WeightedLatLng(latLng, weight: list[1] as double);
}

/// Serialize [LatLng]
Object serializeLatLng(LatLng latLng) {
  return <Object>[latLng.latitude, latLng.longitude];
}

/// Deserialize [LatLng]
LatLng? deserializeLatLng(Object? json) {
  if (json == null) {
    return null;
  }
  assert(json is List && json.length == 2);
  final List<Object?> list = json as List<Object?>;
  return LatLng(list[0]! as double, list[1]! as double);
}

/// Serialize [HeatmapGradient]
Object serializeHeatmapGradient(HeatmapGradient gradient) {
  final Map<String, Object> json = <String, Object>{};

  _addIfNonNull(
    json,
    'colors',
    gradient.colors.map((HeatmapGradientColor e) => e.color.value).toList(),
  );
  _addIfNonNull(
    json,
    'startPoints',
    gradient.colors.map((HeatmapGradientColor e) => e.startPoint).toList(),
  );
  _addIfNonNull(json, 'colorMapSize', gradient.colorMapSize);

  return json;
}

/// Deserialize [HeatmapGradient]
HeatmapGradient? deserializeHeatmapGradient(Object? json) {
  if (json == null) {
    return null;
  }
  assert(json is Map);
  final Map<String, Object?> map = (json as Map<Object?, Object?>).cast();
  final List<Color> colors = (map['colors']! as List<Object?>)
      .whereType<int>()
      .map((int e) => Color(e))
      .toList();
  final List<double> startPoints =
      (map['startPoints']! as List<Object?>).whereType<double>().toList();
  final List<HeatmapGradientColor> gradientColors = <HeatmapGradientColor>[];
  for (int i = 0; i < colors.length; i++) {
    gradientColors.add(HeatmapGradientColor(colors[i], startPoints[i]));
  }
  return HeatmapGradient(
    gradientColors,
    colorMapSize: map['colorMapSize'] as int? ?? 256,
  );
}
