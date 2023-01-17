// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages all the [TileOverlayController]s associated to a [GoogleMapController].
class TileOverlaysController {
  /// The [gmaps.GMap] instance that this controller operates on.
  late gmaps.GMap googleMap;

  final Map<TileOverlayId, TileOverlayController> _tileOverlays =
      <TileOverlayId, TileOverlayController>{};
  final List<TileOverlayController> _visibleTileOverlays =
      <TileOverlayController>[];

  void _insertZSorted(TileOverlayController tileOverlayController) {
    final int index = _visibleTileOverlays.lowerBoundBy<num>(
        tileOverlayController,
        (TileOverlayController c) => c.tileOverlay.zIndex);

    googleMap.overlayMapTypes!.insertAt(index, tileOverlayController.gmMapType);
    _visibleTileOverlays.insert(index, tileOverlayController);
  }

  void _removeZSorted(TileOverlayController tileOverlayController) {
    final int index = _visibleTileOverlays.indexOf(tileOverlayController);
    googleMap.overlayMapTypes!.removeAt(index);
    _visibleTileOverlays.removeAt(index);
  }

  /// Adds new [TileOverlay]s to this controller.
  ///
  /// Wraps the [TileOverlay]s in corresponding [TileOverlayController]s.
  void addTileOverlays(Set<TileOverlay> tileOverlays) {
    for (final TileOverlay tileOverlay in tileOverlays) {
      final TileOverlayController controller = TileOverlayController()
        ..update(tileOverlay);
      _tileOverlays[tileOverlay.tileOverlayId] = controller;

      if (tileOverlay.visible) {
        _insertZSorted(controller);
      }
    }
  }

  /// Updates [TileOverlay]s with new options.
  void changeTileOverlays(Set<TileOverlay> tileOverlays) {
    for (final TileOverlay tileOverlay in tileOverlays) {
      final TileOverlayController controller =
          _tileOverlays[tileOverlay.tileOverlayId]!;

      final bool wasVisible = controller.tileOverlay.visible;
      final bool zIndexChanged =
          tileOverlay.zIndex != controller.tileOverlay.zIndex;
      if (wasVisible && !tileOverlay.visible || zIndexChanged) {
        _removeZSorted(controller);
      }

      controller.update(tileOverlay);

      if (tileOverlay.visible) {
        if (!wasVisible || zIndexChanged) {
          _insertZSorted(controller);
        } else {
          final int i = _visibleTileOverlays.indexOf(controller);
          googleMap.overlayMapTypes!.setAt(i, controller.gmMapType);
        }
      }
    }
  }

  /// Removes the tile overlays associated with the given [TileOverlayId]s.
  void removeTileOverlays(Set<TileOverlayId> tileOverlayIds) {
    for (final TileOverlayId id in tileOverlayIds) {
      final TileOverlayController controller = _tileOverlays.remove(id)!;
      if (controller.tileOverlay.visible) {
        _removeZSorted(controller);
      }
    }
  }

  /// Invalidates the tile overlay associated with the given [TileOverlayId].
  void clearTileCache(TileOverlayId tileOverlayId) {
    final TileOverlayController? controller = _tileOverlays[tileOverlayId];
    if (controller == null || !controller.tileOverlay.visible) {
      return;
    }

    final int i = _visibleTileOverlays.indexOf(controller);
    googleMap.overlayMapTypes!.setAt(i, controller.gmMapType);
    // It's that simple; this causes the map to reload the overlay.
  }
}
