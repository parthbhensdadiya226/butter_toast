import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'web_icon.dart';
import 'web_icon_url.dart' if (dart.library.js_interop) 'web_icon_url_web.dart';

/// The app's own launcher icon, read from the platform at run time, so it
/// always matches the icon your users see on their home screen.
///
/// Use it as the toast icon in your theme:
///
/// ```dart
/// ButterToastTheme(icon: ButterToastAppIcon())
/// ```
///
/// On Android it is the launcher icon, shown round like the launcher does.
/// On iOS it is the icon from `Info.plist`, with rounded corners. On the web
/// it is the icon listed in your web app manifest (`web/manifest.json`),
/// falling back to `icons/Icon-192.png`. If the icon can't be read, nothing
/// is shown.
class ButterToastAppIcon extends StatefulWidget {
  /// Creates the launcher icon, [size] logical pixels wide.
  const ButterToastAppIcon({super.key, this.size = 18});

  /// Width and height of the icon.
  final double size;

  static const _channel = MethodChannel('butter_toast');
  static Future<Uint8List?>? _bytes;
  static Future<String>? _webUrl;

  /// The launcher icon as PNG bytes, read once and then cached.
  static Future<Uint8List?> _load() => _bytes ??= () async {
    try {
      return await _channel.invokeMethod<Uint8List>('appIcon', {'size': 96});
    } on Object {
      return null;
    }
  }();

  /// The web icon's URL, looked up in the manifest once and then cached.
  static Future<String> _loadWebUrl() =>
      _webUrl ??= webIconUrl().then((url) => url ?? defaultWebIcon);

  @override
  State<ButterToastAppIcon> createState() => _ButterToastAppIconState();
}

class _ButterToastAppIconState extends State<ButterToastAppIcon> {
  late final Future<Uint8List?>? _bytes = kIsWeb
      ? null
      : ButterToastAppIcon._load();
  late final Future<String>? _webUrl = kIsWeb
      ? ButterToastAppIcon._loadWebUrl()
      : null;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    Widget clip(Widget image) {
      final round = defaultTargetPlatform == TargetPlatform.android;
      return round
          ? ClipOval(child: image)
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.23),
              child: image,
            );
    }

    Widget empty() => SizedBox.square(dimension: size);

    if (kIsWeb) {
      Widget network(String url, Widget Function() onError) => Image.network(
        url,
        width: size,
        height: size,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => onError(),
      );
      return FutureBuilder<String>(
        future: _webUrl,
        builder: (context, snapshot) {
          final url = snapshot.data;
          if (url == null) return empty();
          // If the manifest's icon fails to load, try the default one.
          return clip(
            network(
              url,
              () => url == defaultWebIcon
                  ? empty()
                  : network(defaultWebIcon, empty),
            ),
          );
        },
      );
    }
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return empty();
        return clip(
          Image.memory(
            bytes,
            width: size,
            height: size,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
        );
      },
    );
  }
}
