package io.flutter.plugins.googlemaps;

public class TileOverlaySpec {
    final String rawUrl;
    final int width;
    final int height;
    final float transparency;
    final boolean fadeIn;
    final boolean isVisible;
    final float zIndex;
    public TileOverlaySpec(String rawUrl, int width, int height, float transparency, boolean fadeIn, boolean isVisible, float zIndex) {
        this.rawUrl = rawUrl;
        this.width = width;
        this.height = height;
        this.transparency = transparency;
        this.fadeIn = fadeIn;
        this.isVisible = isVisible;
        this.zIndex = zIndex;
    }
}
