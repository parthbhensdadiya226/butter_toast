import 'dart:convert';

/// Path of the icon Flutter puts in every new web app. Used when the
/// manifest has no usable icon.
const defaultWebIcon = 'icons/Icon-192.png';

/// Picks the app icon from a web app [manifest] (the text of
/// `manifest.json`), resolved against [manifestUrl].
///
/// Prefers icons meant for general use over maskable ones, and the smallest
/// icon at least [target] pixels wide. Returns null when there is no icon.
String? pickManifestIcon(String manifest, Uri manifestUrl, {int target = 96}) {
  final Object? json;
  try {
    json = jsonDecode(manifest);
  } on FormatException {
    return null;
  }
  if (json is! Map || json['icons'] is! List) return null;

  final icons = <({String src, int size, bool any})>[];
  for (final icon in json['icons'] as List) {
    if (icon is! Map || icon['src'] is! String) continue;
    final purpose = icon['purpose'] is String
        ? (icon['purpose'] as String).split(' ')
        : const ['any'];
    icons.add((
      src: icon['src'] as String,
      size: _largestSize(icon['sizes']),
      any: purpose.contains('any'),
    ));
  }
  if (icons.isEmpty) return null;

  icons.sort((a, b) {
    // General-purpose icons first: maskable ones are cropped by the system
    // and look too small on their own.
    if (a.any != b.any) return a.any ? -1 : 1;
    final aBig = a.size >= target, bBig = b.size >= target;
    if (aBig != bBig) return aBig ? -1 : 1;
    // Big enough: the smallest one. Too small: the biggest one.
    return aBig ? a.size.compareTo(b.size) : b.size.compareTo(a.size);
  });
  return manifestUrl.resolve(icons.first.src).toString();
}

/// Width of the largest size in a `sizes` value like `"48x48 192x192"`.
/// `"any"` (an SVG) counts as large.
int _largestSize(Object? sizes) {
  if (sizes is! String) return 0;
  var largest = 0;
  for (final size in sizes.split(' ')) {
    if (size == 'any') return 1 << 20;
    final width = int.tryParse(size.split('x').first) ?? 0;
    if (width > largest) largest = width;
  }
  return largest;
}
