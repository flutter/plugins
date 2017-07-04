// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  }) : assert(identity != null);

  /// A regular expression that matches against the "size directive" path
  /// segment of Google profile image URLs.
  ///
  /// The format is is "`/sNN-c/`", where `NN` is the max width/height of the
  /// image, and "`c`" indicates we want the image cropped.
  static final RegExp sizeDirective = new RegExp(r'^s[0-9]{1,5}(-c)?$');

  final GoogleIdentity identity;
  final String placeholderPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return new CircleAvatar(
      child: new LayoutBuilder(builder: _buildClippedImage),
    );
  }

  /// Adds sizing information to [photoUrl], inserted as the last path segment
  /// before the image filename. The format is described in [sizeDirective].
  static String _sizedProfileImageUrl(String photoUrl, double size) {
    assert(photoUrl != null);
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

    String photoUrl = identity.photoUrl ?? placeholderPhotoUrl;
    if (photoUrl == null && identity.displayName != null) {
      // Display the user's initials rather than a profile photo.
      return new Text(identity.displayName.substring(0, 1));
    }

    // Add a sizing directive to the profile photo URL if we have one.
    final double size = MediaQuery.of(context).devicePixelRatio * constraints.maxWidth;
    if (photoUrl != null) {
      photoUrl = _sizedProfileImageUrl(photoUrl, size);
    }

    // If the user has no profile photo and no display name, fall back to
    // the default profile photo as a last resort.
    photoUrl ??= 'https://lh3.googleusercontent.com/a/default-user=s${size.round()}-c';

    return new ClipOval(
      child: new Image(
        image: new NetworkImage(photoUrl),
      ),
    );
  }
}
