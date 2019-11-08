/// A regular expression that matches against the "size directive" path
/// segment of Google profile image URLs.
///
/// The format is is "`/sNN-c/`", where `NN` is the max width/height of the
/// image, and "`c`" indicates we want the image cropped.
final RegExp sizeDirective = RegExp(r'^s[0-9]{1,5}(-c)?$');

/// Adds sizing information to [photoUrl], inserted as the last path segment
/// before the image filename. The format is described in [sizeDirective].
///
/// Falls back to the default profile photo if [photoUrl] is [null].
String addSizeDirectiveToUrl(String photoUrl, double size) {
  if (photoUrl == null) {
    // If the user has no profile photo and no display name, fall back to
    // the default profile photo as a last resort.
    return 'https://lh3.googleusercontent.com/a/default-user=s${size.round()}-c';
  }
  final Uri profileUri = Uri.parse(photoUrl);
  final List<String> pathSegments = List<String>.from(profileUri.pathSegments);
  if (pathSegments.length <= 2) {
    /// New URLs may have directives at the end of the URL, like "`=sNN-c`".
    /// Each filter is separated by dashes. Filters may contain = signs:
    /// "`=s120-c-fSoften=1,50,0`"
    final String imagePath = pathSegments.last;
    // Locate the first =
    final int directiveSeparator = imagePath.indexOf('=');
    if (directiveSeparator >= 0) {
      // Split the image URL by the first =
      final String image = imagePath.substring(0, directiveSeparator);
      final String directive = imagePath.substring(directiveSeparator + 1);
      // Split the second half by -
      final Set<String> directives = Set<String>.from(directive.split('-'))
        // Remove the size directive, if present, and empty values
        ..removeWhere((String s) => s.isEmpty || sizeDirective.hasMatch(s))
        // Add the size and crop directives
        ..addAll(<String>['c', 's${size.round()}']);

      pathSegments.last = '$image=${directives.join("-")}';
    } else {
      pathSegments.last = '${pathSegments.last}=c-s${size.round()}';
    }
  } else {
    // Old style URLs
    pathSegments
      ..removeWhere(sizeDirective.hasMatch)
      ..insert(pathSegments.length - 1, 's${size.round()}-c');
  }
  return Uri(
    scheme: profileUri.scheme,
    host: profileUri.host,
    pathSegments: pathSegments,
  ).toString();
}
