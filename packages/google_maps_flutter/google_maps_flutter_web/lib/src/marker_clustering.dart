// ignore_for_file: public_member_api_docs, non_constant_identifier_names
part of google_maps_flutter_web;

typedef ClusterClickHandler = void Function(
    gmaps.MapMouseEvent, MarkerClustererCluster, gmaps.GMap);

class ClusterManagersController extends GeometryController {
  ClusterManagersController(
      {required StreamController<MapEvent<Object?>> stream})
      : _streamController = stream,
        _clusterManagerIdToMarkerClusterer =
            <ClusterManagerId, MarkerClusterer>{};

  // The stream over which cluster managers broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  // A cache of [MarkerClusterer]s indexed by their [ClusterManagerId].
  final Map<ClusterManagerId, MarkerClusterer>
      _clusterManagerIdToMarkerClusterer;

  /// Adds a set of [ClusterManager] objects to the cache.
  void addClusterManagers(Set<ClusterManager> clusterManagersToAdd) {
    clusterManagersToAdd.forEach(_addClusterManager);
  }

  void _addClusterManager(ClusterManager clusterManager) {
    if (clusterManager == null) {
      return;
    }

    final MarkerClusterer markerClusterer = createMarkerClusterer(
        googleMap,
        (gmaps.MapMouseEvent event, MarkerClustererCluster cluster,
                gmaps.GMap map) =>
            _clusterClicked(
                clusterManager.clusterManagerId, event, cluster, map));

    _clusterManagerIdToMarkerClusterer[clusterManager.clusterManagerId] =
        markerClusterer;
    markerClusterer.onAdd();
  }

  /// Removes a set of [ClusterManagerId]s from the cache.
  void removeClusterManagers(Set<ClusterManagerId> clusterManagerIdsToRemove) {
    clusterManagerIdsToRemove.forEach(_removeClusterManager);
  }

  void _removeClusterManager(ClusterManagerId clusterManagerId) {
    final MarkerClusterer? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      markerClusterer.onRemove();
      markerClusterer.clearMarkers(true);
    }
    _clusterManagerIdToMarkerClusterer.remove(clusterManagerId);
  }

  /// Adds given [gmaps.Marker] to the [MarkerClusterer] with given [ClusterManagerId].
  void addItem(ClusterManagerId clusterManagerId, gmaps.Marker marker) {
    final MarkerClusterer? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      markerClusterer.addMarker(marker, false);
    }
  }

  /// Removes given [gmaps.Marker] from the [MarkerClusterer] with given [ClusterManagerId].
  void removeItem(ClusterManagerId clusterManagerId, gmaps.Marker? marker) {
    if (marker != null) {
      final MarkerClusterer? markerClusterer =
          _clusterManagerIdToMarkerClusterer[clusterManagerId];
      if (markerClusterer != null) {
        markerClusterer.removeMarker(marker, false);
      }
    }
  }

  /// Returns list of clusters in [MarkerClusterer] with given [ClusterManagerId].
  List<Cluster> getClusters(ClusterManagerId clusterManagerId) {
    final MarkerClusterer? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      return markerClusterer.clusters
          .map((MarkerClustererCluster cluster) =>
              _convertCluster(clusterManagerId, cluster))
          .toList();
    }
    return <Cluster>[];
  }

  void _clusterClicked(
      ClusterManagerId clusterManagerId,
      gmaps.MapMouseEvent event,
      MarkerClustererCluster markerClustererCluster,
      gmaps.GMap map) {
    if (markerClustererCluster.count > 0 &&
        markerClustererCluster.bounds != null &&
        markerClustererCluster.markers != null) {
      final Cluster cluster =
          _convertCluster(clusterManagerId, markerClustererCluster);
      _streamController.add(ClusterTapEvent(mapId, cluster));
    }
  }

  /// Converts [MarkerClustererCluster] to [Cluster].
  Cluster _convertCluster(ClusterManagerId clusterManagerId,
      MarkerClustererCluster markerClustererCluster) {
    final LatLng position = _gmLatLngToLatLng(markerClustererCluster.position);
    final LatLngBounds bounds =
        _gmLatLngBoundsTolatLngBounds(markerClustererCluster.bounds!);

    final List<MarkerId> markerIds = markerClustererCluster.markers!
        .map<MarkerId>((gmaps.Marker marker) =>
            MarkerId(marker.get('markerId')! as String))
        .toList();
    return Cluster(clusterManagerId, position, bounds, markerIds);
  }
}

@JS()
external ClusterClickHandler defaultOnClusterClickHandler;

@JS()
@anonymous
class MarkerClustererOptions {
  external factory MarkerClustererOptions();

  external gmaps.GMap? get map;

  external set map(gmaps.GMap? map);

  external List<gmaps.Marker>? get markers;

  external set markers(List<gmaps.Marker>? markers);

  external ClusterClickHandler? get onClusterClick;

  external set onClusterClick(ClusterClickHandler? handler);
}

@JS('markerClusterer.Cluster')
class MarkerClustererCluster {
  external gmaps.Marker get marker;
  external List<gmaps.Marker>? markers;

  external gmaps.LatLngBounds? get bounds;
  external gmaps.LatLng get position;

  /// Get the count of **visible** markers.
  external int get count;

  external void delete();
  external void push(gmaps.Marker marker);
}

@JS('markerClusterer.MarkerClusterer')
class MarkerClusterer {
  external MarkerClusterer(MarkerClustererOptions options);

  external void addMarker(gmaps.Marker marker, bool? noDraw);
  external void addMarkers(List<gmaps.Marker>? markers, bool? noDraw);
  external bool removeMarker(gmaps.Marker marker, bool? noDraw);
  external bool removeMarkers(List<gmaps.Marker>? markers, bool? noDraw);
  external void clearMarkers(bool? noDraw);
  external void onAdd();
  external void onRemove();
  external List<MarkerClustererCluster> get clusters;

  /// Recalculates and draws all the marker clusters.
  external void render();
}

MarkerClusterer createMarkerClusterer(
    gmaps.GMap map, ClusterClickHandler onClusterClickHandler) {
  return MarkerClusterer(createClusterOptions(map, onClusterClickHandler));
}

MarkerClustererOptions createClusterOptions(
    gmaps.GMap map, ClusterClickHandler onClusterClickHandler) {
  final MarkerClustererOptions options = MarkerClustererOptions()
    ..map = map
    ..onClusterClick = allowInterop(onClusterClickHandler);

  return options;
}
