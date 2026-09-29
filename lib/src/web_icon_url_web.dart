import 'dart:js_interop';

import 'web_icon.dart';

@JS('document')
external _Document get _document;

extension type _Document._(JSObject _) implements JSObject {
  external _Link? querySelector(String selectors);
}

extension type _Link._(JSObject _) implements JSObject {
  /// The link's URL, already resolved against the page.
  external String get href;
}

@JS('fetch')
external JSPromise<_Response> _fetch(String url);

extension type _Response._(JSObject _) implements JSObject {
  external bool get ok;
  external JSPromise<JSString> text();
}

/// The app icon URL from the web app manifest linked in `index.html`, or
/// null if there is no manifest or it has no icon.
Future<String?> webIconUrl() async {
  try {
    final link = _document.querySelector('link[rel="manifest"]');
    if (link == null) return null;
    final manifestUrl = Uri.parse(link.href);
    final response = await _fetch(manifestUrl.toString()).toDart;
    if (!response.ok) return null;
    final text = (await response.text().toDart).toDart;
    return pickManifestIcon(text, manifestUrl);
  } on Object {
    return null;
  }
}
