import 'dart:html';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// Convert list of XTypeGroups to a comma-separated string
String acceptedTypesToString(List<XTypeGroup> acceptedTypes) {
  if (acceptedTypes == null) return '';
  final List<String> allTypes = [];
  for (final group in acceptedTypes) {
    _assertTypeGroupIsValid(group);
    if (group.extensions != null) {
      allTypes.addAll(group.extensions.map(_normalizeExtension));
    }
    if (group.mimeTypes != null) {
      allTypes.addAll(group.mimeTypes);
    }
    if (group.webWildCards != null) {
      allTypes.addAll(group.webWildCards);
    }
  }
  return allTypes.join(',');
}

/// Helper to convert an html.File to an XFile
XFile convertFileToXFile(File file) => XFile(
      Url.createObjectUrl(file),
      name: file.name,
      length: file.size,
      lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
    );

/// Make sure that at least one of its fields is populated.
void _assertTypeGroupIsValid(XTypeGroup group) {
  assert(
      !((group.extensions == null || group.extensions.isEmpty) &&
          (group.mimeTypes == null || group.mimeTypes.isEmpty) &&
          (group.webWildCards == null || group.webWildCards.isEmpty)),
      'At least one of extensions / mimeTypes / webWildCards is required for web.');
}

/// Append a dot at the beggining if it is not there png -> .png
String _normalizeExtension(String ext) {
  return ext.isNotEmpty && ext[0] != '.' ? '.' + ext : ext;
}
