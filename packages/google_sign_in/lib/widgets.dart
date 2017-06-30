// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'src/common.dart';

/// Builds a CircleAvatar profile image of the appropriate resolution
class GoogleUserCircleAvatar extends StatelessWidget {
  /// Creates a new widget based on the specified identity.
  const GoogleUserCircleAvatar(this._identity) : assert(_identity != null);
  final GoogleIdentity _identity;

  @override
  Widget build(BuildContext context) {
    return new CircleAvatar(
      child: new LayoutBuilder(builder: _buildClippedImage),
    );
  }

  /// Adds sizing information to the URL, inserted as the last path segment
  /// before the image filename. The format is "`/sNN-c/`", where `NN` is the
  /// max width/height of the image, and "`c`" indicates we want the image
  /// cropped.
  String _sizedProfileImageUrl(double size) {
    assert(_identity.photoUrl != null);
    final Uri profileUri = Uri.parse(_identity.photoUrl);
    final List<String> pathSegments =
        new List<String>.from(profileUri.pathSegments);
    pathSegments.remove("s1337"); // placeholder value added by iOS plugin
    pathSegments.insert(pathSegments.length - 1, "s${size.round()}-c");
    return new Uri(
      scheme: profileUri.scheme,
      host: profileUri.host,
      pathSegments: pathSegments,
    )
        .toString();
  }

  Widget _buildClippedImage(BuildContext context, BoxConstraints constraints) {
    assert(constraints.maxWidth == constraints.maxHeight);
    if (_identity.photoUrl == null) {
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
