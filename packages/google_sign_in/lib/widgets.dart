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

  /// Adds sizing information to the URL, inserted as the last path segment
  /// before the image filename. The format is described in [sizeDirective].
  String _sizedProfileImageUrl(double size) {
    final String photoUrl = identity.photoUrl ?? placeholderPhotoUrl;
    assert(photoUrl != null);
    final Uri profileUri = Uri.parse(photoUrl);
    final List<String> pathSegments =
        new List<String>.from(profileUri.pathSegments);
    pathSegments
      ..removeWhere(sizeDirective.hasMatch)
      ..insert(pathSegments.length - 1, "s${size.round()}-c");
    return new Uri(
      scheme: profileUri.scheme,
      host: profileUri.host,
      pathSegments: pathSegments,
    )
        .toString();
  }

  Widget _buildClippedImage(BuildContext context, BoxConstraints constraints) {
    assert(constraints.maxWidth == constraints.maxHeight);
    if (identity.photoUrl == null && placeholderPhotoUrl == null) {
      // TODO(tvolkert): render a placeholder avatar. Typically, this is the
      //                 first letter in the user's display name.
      return new Container();
    } else {
      return new ClipOval(
        child: new Image(
          image: new NetworkImage(
            _sizedProfileImageUrl(
              MediaQuery.of(context).devicePixelRatio * constraints.maxWidth,
            ),
          ),
        ),
      );
    }
  }
}
