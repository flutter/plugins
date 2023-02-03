// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart'
    show
        AssetBundle,
        AssetBundleImageKey,
        AssetImage,
        ImageConfiguration,
        Size,
        WidgetsBinding;

/// Type of bitmap scaling options to use on BitmapDescriptor creation.
enum BitmapScaling {
  /// Automatically scale image with devices pixel ratio or to given size,
  /// to keep marker sizes same between platforms and devices.
  auto,

  /// Render marker to the map as without scaling, this can be used if the image
  /// is already pre-scaled, or to increase performance with large marker amounts.
  noScaling,
}

/// Defines a bitmap image. For a marker, this class can be used to set the
/// image of the marker icon. For a ground overlay, it can be used to set the
/// image to place on the surface of the earth.
class BitmapDescriptor {
  const BitmapDescriptor._(this._json);

  /// The inverse of .toJson.
  // TODO(stuartmorgan): Remove this in the next breaking change.
  @Deprecated('No longer supported')
  BitmapDescriptor.fromJson(Object json) : _json = json {
    assert(_json is List<dynamic>);
    final List<dynamic> jsonList = json as List<dynamic>;
    assert(_validTypes.contains(jsonList[0]));
    switch (jsonList[0]) {
      case _defaultMarker:
        assert(jsonList.length <= 2);
        if (jsonList.length == 2) {
          assert(jsonList[1] is num);
          final num secondElement = jsonList[1] as num;
          assert(0 <= secondElement && secondElement < 360);
        }
        break;
      case _fromBytes:
        assert(jsonList.length == 2);
        assert(jsonList[1] != null && jsonList[1] is List<int>);
        assert((jsonList[1] as List<int>).isNotEmpty);
        break;
      case _fromAsset:
        assert(jsonList.length <= 3);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        if (jsonList.length == 3) {
          assert(jsonList[2] != null && jsonList[2] is String);
          assert((jsonList[2] as String).isNotEmpty);
        }
        break;
      case _fromAssetImage:
        assert(jsonList.length <= 4);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        assert(jsonList[2] != null && jsonList[2] is double);
        if (jsonList.length == 4) {
          assert(jsonList[3] != null && jsonList[3] is List<dynamic>);
          assert((jsonList[3] as List<dynamic>).length == 2);
        }
        break;
      default:
        break;
    }
  }

  static const String _defaultMarker = 'defaultMarker';
  static const String _asset = 'asset';
  static const String _bytes = 'bytes';

  @Deprecated('No longer supported')
  static const String _fromAsset = 'fromAsset';
  @Deprecated('No longer supported')
  static const String _fromAssetImage = 'fromAssetImage';
  @Deprecated('No longer supported')
  static const String _fromBytes = 'fromBytes';

  /// Value representing auto scaling parameter.
  static const String bitmapAutoScaling = 'auto';

  /// Value representing auto no scaling parameter.
  static const String bitmapNoScaling = 'noScaling';

  static const Set<String> _validTypes = <String>{
    _defaultMarker,
    _fromAsset,
    _fromAssetImage,
    _fromBytes,
    _asset,
    _bytes
  };

  /// Convenience hue value representing red.
  static const double hueRed = 0.0;

  /// Convenience hue value representing orange.
  static const double hueOrange = 30.0;

  /// Convenience hue value representing yellow.
  static const double hueYellow = 60.0;

  /// Convenience hue value representing green.
  static const double hueGreen = 120.0;

  /// Convenience hue value representing cyan.
  static const double hueCyan = 180.0;

  /// Convenience hue value representing azure.
  static const double hueAzure = 210.0;

  /// Convenience hue value representing blue.
  static const double hueBlue = 240.0;

  /// Convenience hue value representing violet.
  static const double hueViolet = 270.0;

  /// Convenience hue value representing magenta.
  static const double hueMagenta = 300.0;

  /// Convenience hue value representing rose.
  static const double hueRose = 330.0;

  /// Creates a BitmapDescriptor that refers to the default marker image.
  static const BitmapDescriptor defaultMarker =
      BitmapDescriptor._(<Object>[_defaultMarker]);

  /// Creates a BitmapDescriptor that refers to a colorization of the default
  /// marker image. For convenience, there is a predefined set of hue values.
  /// See e.g. [hueYellow].
  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    assert(0.0 <= hue && hue < 360.0);
    return BitmapDescriptor._(<Object>[_defaultMarker, hue]);
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  /// Set `mipmaps` to false to load the exact dpi version of the image, `mipmap` is true by default.
  @Deprecated('No longer supported')
  static Future<BitmapDescriptor> fromAssetImage(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    bool mipmaps = true,
  }) async {
    final double? devicePixelRatio = configuration.devicePixelRatio;
    if (!mipmaps && devicePixelRatio != null) {
      return BitmapDescriptor._(<Object>[
        _fromAssetImage,
        assetName,
        devicePixelRatio,
      ]);
    }
    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);
    final Size? size = configuration.size;
    return BitmapDescriptor._(<Object>[
      _fromAssetImage,
      assetBundleImageKey.name,
      assetBundleImageKey.scale,
      if (kIsWeb && size != null)
        <Object>[
          size.width,
          size.height,
        ],
    ]);
  }

  /// Creates a BitmapDescriptor using an array of bytes that must be encoded
  /// as PNG.
  /// On the web, the [size] parameter represents the *physical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// This helps the browser to render High-DPI images at the correct size.
  /// `size` is not required (and ignored, if passed) in other platforms.
  @Deprecated('No longer supported')
  static BitmapDescriptor fromBytes(Uint8List byteData, {Size? size}) {
    assert(byteData.isNotEmpty,
        'Cannot create BitmapDescriptor with empty byteData');
    return BitmapDescriptor._(<Object>[
      _fromBytes,
      byteData,
      if (kIsWeb && size != null)
        <Object>[
          size.width,
          size.height,
        ]
    ]);
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  /// Set `mipmaps` to false to load the exact dpi version of the image, `mipmap` is true by default.
  /// If `mipmaps` is set to false, optional `imagePixelRatio` can be given to
  /// override `devicePixelRatio` value from `ImageConfiguration`.
  static Future<BitmapDescriptor> createFromAsset(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    bool mipmaps = true,
    double? imagePixelRatio,
    BitmapScaling bitmapScaling = BitmapScaling.auto,
  }) async {
    final double devicePixelRatio =
        WidgetsBinding.instance.window.devicePixelRatio;
    final double? targetImagePixelRatio =
        imagePixelRatio ?? configuration.devicePixelRatio;
    final Size? size = configuration.size;

    if (!mipmaps && (targetImagePixelRatio != null || size != null)) {
      return BitmapDescriptor._(<Object>[
        _asset,
        assetName,
        _getBitMapScalingString(bitmapScaling),
        targetImagePixelRatio ?? devicePixelRatio,
        if (size != null)
          <Object>[
            size.width,
            size.height,
          ],
      ]);
    }

    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);

    return BitmapDescriptor._(<Object>[
      _asset,
      assetBundleImageKey.name,
      _getBitMapScalingString(bitmapScaling),
      assetBundleImageKey.scale,
      if (size != null)
        <Object>[
          size.width,
          size.height,
        ],
    ]);
  }

  /// Creates a BitmapDescriptor using an array of bytes that must be encoded
  /// as PNG.
  /// The optional [size] parameter represents the *logical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// This helps the platform to render High-DPI images at the correct size.
  /// [ImagePixelRatio] value can be use to scale the image to
  /// proper size across platforms.
  static BitmapDescriptor createFromBytes(
    Uint8List byteData, {
    BitmapScaling bitmapScaling = BitmapScaling.auto,
    double? imagePixelRatio,
    Size? size,
  }) {
    assert(byteData.isNotEmpty,
        'Cannot create BitmapDescriptor with empty byteData');
    assert(bitmapScaling != BitmapScaling.noScaling || imagePixelRatio == null,
        'If bitmapScaling is set to BitmapScaling.noScaling, scale parameter cannot be used.');
    assert(bitmapScaling != BitmapScaling.noScaling || size == null,
        'If bitmapScaling is set to BitmapScaling.noScaling, size parameter cannot be used.');

    return BitmapDescriptor._(<Object>[
      _bytes,
      byteData,
      _getBitMapScalingString(bitmapScaling),
      imagePixelRatio ?? 1.0,
      if (size != null)
        <Object>[
          size.width,
          size.height,
        ],
    ]);
  }

  static String _getBitMapScalingString(BitmapScaling bitmapScaling) {
    switch (bitmapScaling) {
      case BitmapScaling.auto:
        return bitmapAutoScaling;
      case BitmapScaling.noScaling:
        return bitmapNoScaling;
    }
  }

  final Object _json;

  /// Convert the object to a Json format.
  Object toJson() => _json;
}
