import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
/// it is `icons/Icon-192.png` from your `web` folder. If the icon can't be
/// read, nothing is shown.
class ButterToastAppIcon extends StatefulWidget {
  /// Creates the launcher icon, [size] logical pixels wide.
  const ButterToastAppIcon({super.key, this.size = 18});

  /// Width and height of the icon.
  final double size;

  static const _channel = MethodChannel('butter_toast');
  static Future<Uint8List?>? _bytes;

  /// The launcher icon as PNG bytes, read once and then cached.
  static Future<Uint8List?> _load() => _bytes ??= () async {
    try {
      return await _channel.invokeMethod<Uint8List>('appIcon', {'size': 96});
    } on Object {
      return null;
    }
  }();

  @override
  State<ButterToastAppIcon> createState() => _ButterToastAppIconState();
}

class _ButterToastAppIconState extends State<ButterToastAppIcon> {
  late final Future<Uint8List?>? _bytes = kIsWeb
      ? null
      : ButterToastAppIcon._load();

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
      return clip(
        Image.network(
          'icons/Icon-192.png',
          width: size,
          height: size,
          errorBuilder: (_, _, _) => empty(),
        ),
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
