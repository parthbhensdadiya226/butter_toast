import 'package:butter_toast/src/web_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = Uri.parse('https://example.com/app/manifest.json');

  test('picks the smallest general-purpose icon that is big enough', () {
    const manifest = '''
{"icons": [
  {"src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png"},
  {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"},
  {"src": "icons/Icon-48.png", "sizes": "48x48", "type": "image/png"},
  {"src": "icons/Icon-maskable-192.png", "sizes": "192x192",
   "purpose": "maskable"}
]}''';
    expect(
      pickManifestIcon(manifest, base),
      'https://example.com/app/icons/Icon-192.png',
    );
  });

  test('uses the biggest icon when all are small', () {
    const manifest = '''
{"icons": [
  {"src": "a.png", "sizes": "32x32"},
  {"src": "b.png", "sizes": "16x16 64x64"}
]}''';
    expect(pickManifestIcon(manifest, base), 'https://example.com/app/b.png');
  });

  test('falls back to a maskable icon when there is nothing else', () {
    const manifest =
        '{"icons": [{"src": "/m.png", "sizes": "192x192", "purpose": "maskable"}]}';
    expect(pickManifestIcon(manifest, base), 'https://example.com/m.png');
  });

  test('returns null without usable icons', () {
    expect(pickManifestIcon('not json', base), isNull);
    expect(pickManifestIcon('{"name": "App"}', base), isNull);
    expect(pickManifestIcon('{"icons": []}', base), isNull);
  });
}
