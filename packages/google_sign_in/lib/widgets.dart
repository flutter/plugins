// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/common.dart';

/// Builds a CircleAvatar profile image of the appropriate resolution
class GoogleUserCircleAvatar extends StatelessWidget {
  /// Creates a new widget based on the specified [identity].
  ///
  /// If [identity] does not contain a `photoUrl` and [placeholderPhotoUrl] is
  /// specified, then the given URL will be used as the user's photo URL. The
  /// URL must be able to handle a [sizeDirective] path segment.
  ///
  /// If [identity] does not contain a `photoUrl` and [placeholderPhotoUrl] is
  /// *not* specified, then the widget will render the user's first initial
  /// in place of a profile photo, or a default profile photo if the user's
  /// identity does not specify a `displayName`.
  const GoogleUserCircleAvatar({
    @required this.identity,
    this.placeholderPhotoUrl,
    this.backgroundColor,
  })
      : assert(identity != null);

  /// A regular expression that matches against the "size directive" path
  /// segment of Google profile image URLs.
  ///
  /// The format is is "`/sNN-c/`", where `NN` is the max width/height of the
  /// image, and "`c`" indicates we want the image cropped.
  static final RegExp sizeDirective = new RegExp(r'^s[0-9]{1,5}(-c)?$');

  /// The Google user's identity; guaranteed to be non-null.
  final GoogleIdentity identity;

  /// The color with which to fill the circle. Changing the background color
  /// will cause the avatar to animate to the new color.
  ///
  /// If a background color is not specified, the theme's primary color is used.
  final Color backgroundColor;

  /// The URL of a photo to use if the user's [identity] does not specify a
  /// `photoUrl`.
  ///
  /// If this is `null` and the user's [identity] does not contain a photo URL,
  /// then this widget will attempt to display the user's first initial as
  /// determined from the identity's [displayName] field. If that is `null` a
  /// default (generic) Google profile photo will be displayed.
  final String placeholderPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return new CircleAvatar(
      backgroundColor: backgroundColor,
      child: new LayoutBuilder(builder: _buildClippedImage),
    );
  }

  /// Adds sizing information to [photoUrl], inserted as the last path segment
  /// before the image filename. The format is described in [sizeDirective].
  ///
  /// Falls back to the default profile photo if [photoUrl] is [null].
  static String _sizedProfileImageUrl(String photoUrl, double size) {
    if (photoUrl == null) {
      // If the user has no profile photo and no display name, fall back to
      // the default profile photo as a last resort.
      return 'https://lh3.googleusercontent.com/a/default-user=s${size.round()}-c';
    }
    final Uri profileUri = Uri.parse(photoUrl);
    final List<String> pathSegments =
        new List<String>.from(profileUri.pathSegments);
    pathSegments
      ..removeWhere(sizeDirective.hasMatch)
      ..insert(pathSegments.length - 1, 's${size.round()}-c');
    return new Uri(
      scheme: profileUri.scheme,
      host: profileUri.host,
      pathSegments: pathSegments,
    )
        .toString();
  }

  Widget _buildClippedImage(BuildContext context, BoxConstraints constraints) {
    assert(constraints.maxWidth == constraints.maxHeight);

    // Placeholder to use when there is no photo URL, and while the photo is
    // loading. Uses the first character of the display name (if it has one),
    // or the first letter of the email address if it does not.
    final List<String> placeholderCharSources = <String>[
      identity.displayName,
      identity.email,
      '-',
    ];
    final String placeholderChar = placeholderCharSources
        .firstWhere((String str) => str != null && str.trimLeft().isNotEmpty)
        .trimLeft()[0]
        .toUpperCase();
    final Widget placeholder = new Center(
      child: new Text(placeholderChar, textAlign: TextAlign.center),
    );

    final String photoUrl = identity.photoUrl ?? placeholderPhotoUrl;
    if (photoUrl == null) {
      return placeholder;
    }

    // Add a sizing directive to the profile photo URL.
    final double size =
        MediaQuery.of(context).devicePixelRatio * constraints.maxWidth;
    final String sizedPhotoUrl = _sizedProfileImageUrl(photoUrl, size);

    // Fade the photo in over the top of the placeholder.
    return new SizedBox(
        width: size,
        height: size,
        child: new ClipOval(
          child: new Stack(fit: StackFit.expand, children: <Widget>[
            placeholder,
            new FadeInImage.memoryNetwork(
              // This creates a transparent placeholder image, so that
              // [placeholder] shows through.
              placeholder: new Uint8List((size.round() * size.round())),
              image: sizedPhotoUrl,
            )
          ]),
        ));
  }
}
