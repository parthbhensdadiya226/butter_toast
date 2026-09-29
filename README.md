<div align="center">

# 🧈 butter_toast

**Toasts that feel smooth as butter.**

Pill and Sonner-style card toasts for Flutter, with spring animations,
seven positions that each move their own way, promise toasts, and swipe to
dismiss. No `BuildContext` needed.

[![pub package](https://img.shields.io/pub/v/butter_toast.svg)](https://pub.dev/packages/butter_toast)
[![likes](https://img.shields.io/pub/likes/butter_toast)](https://pub.dev/packages/butter_toast/score)
[![pub points](https://img.shields.io/pub/points/butter_toast)](https://pub.dev/packages/butter_toast/score)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/hero.gif" width="280" alt="Card toasts stacking, spreading out and swiping away">

</div>

---

## ✨ Why butter_toast?

`fluttertoast` shows the native Android toast, and since Android 11 the
system cuts that toast to **two lines**, ignores your position and blocks
custom layouts. Most Flutter alternatives fix that by drawing a wide
**snackbar**. butter_toast draws a real **toast**: small, light, and out of
your way.

| | |
|---|---|
| 🍞 **Two styles** | A compact **pill** like the native toast, or a **card** with title and description that stacks like [Sonner](https://sonner.emilkowal.ski) |
| 🎯 **7 positions** | Top and bottom slide from their edge, corners slide in from the side, centre scales in |
| 🌀 **Spring motion** | Enter with a soft bounce, swipe away **in any direction**, interrupt any animation smoothly |
| 👆 **Swipe any toast** | Even one from the middle of a spread-out stack; the rest close the gap |
| ⏳ **Promise toasts** | `Saving…` → `Saved ✓` in the same toast |
| 📏 **Never covers the screen** | Long text collapses behind **Show more**, inside a height budget |
| ⌨️ **Keyboard and safe area aware** | Stays clear of the notch, home indicator and keyboard |
| 🪟 **Above everything** | Shows over dialogs and bottom sheets |
| 🖼️ **Your app icon** | Show the real launcher icon on toasts, read at run time, no asset needed |
| 🧹 **No pile-ups** | Repeated taps merge into one toast; a `tag` updates a toast in place |
| 🧵 **No context needed** | Call it from blocs, services or a Dio interceptor |
| 🎨 **Themeable** | A `ThemeExtension` with light and dark defaults, or build your own toast |
| ♿ **Accessible** | Screen readers announce toasts; reduced motion fades instead of sliding |
| 📦 **Zero dependencies** | Only the Flutter SDK |

## 🎬 See it move

| Swipe any toast, any direction | Corners slide in from the side | Promise: loading → success |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/swipe.gif" width="220" alt="Toasts in a spread stack swiped away diagonally, up and sideways, starting with the middle one"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/positions.gif" width="220" alt="Card toasts sliding in from each corner"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/promise.gif" width="220" alt="A loading pill turning into a success pill"> |

| Pill | Card | Long message |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/pill.png" width="220" alt="Pill toast"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/card.png" width="220" alt="Card toast with description"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/long.png" width="220" alt="Long message collapsed behind Show more"> |

## 🚀 Getting started

```yaml
dependencies:
  butter_toast: ^0.1.0
```

Add one line to your app:

```dart
import 'package:butter_toast/butter_toast.dart';

MaterialApp(
  builder: ButterToast.init(), // 👈 that's it
  home: const HomePage(),
);
```

Then toast from anywhere:

```dart
ButterToast.show('Copied to clipboard');
ButterToast.success('Event created', description: 'Sunday, 9:00 AM');
ButterToast.error("Couldn't send", description: 'Check your connection.');
ButterToast.warning('Storage almost full');
ButterToast.info('New version available');
```

## ⏳ Promise toasts

One toast follows your future from start to finish:

```dart
final photos = await ButterToast.promise(
  api.uploadPhotos(),
  loading: 'Uploading photos…',
  success: (count) => '$count photos uploaded',
  error: (e) => "Couldn't upload your photos",
);
```

Or drive it yourself with the handle:

```dart
final toast = ButterToast.loading('Syncing…');
// later
toast.update(message: 'All synced', type: ButterToastType.success);
// or
toast.dismiss();
```

## 🎯 Positions

```dart
ButterToast.show('Hi', position: ButterToastPosition.topRight);
```

| Position | Enters | Leaves / swipe | Stack grows |
|---|---|---|---|
| `topCenter` | ⬇️ from the top | ⬆️ up | down |
| `bottomCenter` (default) | ⬆️ from the bottom | ⬇️ down | up |
| `topLeft`, `bottomLeft` | ➡️ from the left edge | ⬅️ left | away from the edge |
| `topRight`, `bottomRight` | ⬅️ from the right edge | ➡️ right | away from the edge |
| `center` | 🔍 scales in | fades | replaces the last one |

## 🍞 Pill or 🃏 card

```dart
ButterToast.show('Saved', style: ButterToastStyle.pill);
ButterToast.show(
  'Payment received',
  description: '₹1,200 from Sam',
  style: ButterToastStyle.card,
);
```

- **Pill** hugs its text, like the platform toast. Great for "Copied" or
  "Saved".
- **Card** shows a title and description. Several cards stack like a deck;
  **tap** (or hover on web) to spread them out.

While a stack is spread out, its timers pause so nothing disappears while
you read. It closes again when you **tap anywhere else**, or on its own
after **5 seconds** without a touch, and then the toasts leave as usual.

## 👆 Swipe to dismiss

Throw a toast **in any direction** to dismiss it: up, down, sideways or
diagonally. A short drag springs back. In a spread-out stack every toast
can be swiped on its own, including the ones in the middle.

## 🧹 Repeated taps

Showing a toast identical to one already on screen restarts that toast
instead of adding a copy, so a button tapped five times shows one toast.
For toasts that change, give them a `tag`: a new toast with the same tag
**updates the existing one in place**.

```dart
ButterToast.loading('Saving…', tag: 'save');
// later, or on the next tap:
ButterToast.success('Saved', tag: 'save'); // same toast, now a success
```

## 🖼️ App icon

Show your app's launcher icon on toasts, the way Android shows it on native
toasts. It's read from the platform at run time, so it always matches the
icon on the home screen. There's no asset to add or keep in sync:

```dart
ButterToastTheme(
  icon: ButterToastAppIcon(), // plain toasts show the app icon
  typeIcons: false,           // success, error, … show it too
)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/app_icon.png" width="280" alt="Three toasts showing the app's launcher icon instead of type icons">
</p>

| Platform | Icon used |
|---|---|
| Android | The launcher icon, shown round like the launcher does |
| iOS | The app icon from `Info.plist`, with rounded corners |
| Web | `web/icons/Icon-192.png` |

Any widget works as the icon, such as `Image.asset('assets/logo.png')`. To
hide the icon on one toast, pass `showIcon: false`.

## 🪟 Dialogs and bottom sheets

Toasts live above the `Navigator`, so they always show **on top of**
dialogs and bottom sheets, and aren't dimmed by their barrier.

| Over a dialog | Over a bottom sheet |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/dialog.png" width="220" alt="A toast shown above an open dialog, not dimmed by its barrier"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/bottom_sheet.png" width="220" alt="A top toast and a bottom toast shown above an open bottom sheet"> |

- **Dialog:** the toast appears at its usual position, above the dialog.
- **Bottom sheet:** a bottom toast floats over the sheet's lower edge. To
  keep the sheet clear, show it at the top:

```dart
ButterToast.success('Link copied', position: ButterToastPosition.topCenter);
```

## 📏 Long text, keyboard and safe area

A toast never takes over the screen:

- All toasts at one position share a **height budget**: 40% of the safe
  height by default.
- Text that doesn't fit ends with **Show more**. Tapping it shows the full
  text, scrolling inside the toast if needed, and pauses the timer.
- When the keyboard opens, toasts move above it and the budget shrinks with
  the space left. If there's no room at all, bottom toasts move to the top.
- The notch, status bar, home indicator and landscape cutouts are always
  avoided. Use `bottomOffset` to float above your bottom navigation bar.

## 🎨 Theming

butter_toast reads a `ThemeExtension`, so light and dark themes just work:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      ButterToastTheme(
        style: ButterToastStyle.card,
        position: ButterToastPosition.topCenter,
        duration: Duration(seconds: 3),
        bottomOffset: 80,        // above a NavigationBar
        maxHeightFraction: 0.4,  // height budget
        maxLines: 3,             // lines before "Show more"
        cardBorderRadius: 16,
        successColor: Color(0xFF16A34A),
      ),
    ],
  ),
  darkTheme: ThemeData.dark().copyWith(
    extensions: const [ButterToastTheme(style: ButterToastStyle.card)],
  ),
  builder: ButterToast.init(),
);
```

<details>
<summary><b>All theme options</b></summary>

| Option | Default | What it does |
|---|---|---|
| `style` | `pill` | Default look |
| `position` | `bottomCenter` | Default position |
| `duration` | 4 s | How long toasts stay (`Duration.zero` = until dismissed) |
| `maxHeightFraction` | 0.4 | Share of the safe height toasts may use |
| `maxLines` | 3 | Lines before "Show more" |
| `maxWidth` | 420 | Widest a toast gets (tablet, web) |
| `bottomOffset` | 0 | Extra space above the bottom edge |
| `margin` | 16 | Distance from the safe area |
| `gap` | 8 | Space between spread-out cards |
| `visibleCount` | 3 | Cards peeking out of a stack |
| `maxToasts` | 5 | Most toasts per position |
| `cardColor`, `cardForegroundColor`, `cardBorderColor`, `cardBorderRadius` | from `ColorScheme` | Card look |
| `pillColor`, `pillForegroundColor` | dark pill / light pill | Pill look |
| `successColor`, `errorColor`, `warningColor`, `infoColor` | green, red, amber, blue | Icon colours |
| `textStyle` | `bodyMedium` | Base text style |
| `shadows` | soft shadow | Shadows under toasts |
| `icon` | none | Icon for plain toasts, e.g. `ButterToastAppIcon()` |
| `typeIcons` | `true` | `false` shows `icon` on every toast instead of type icons |

</details>

## 🧩 Fully custom toasts

Draw anything; butter_toast still animates, stacks, times and positions it:

```dart
ButterToast.custom(
  builder: (context, toast) => MyBrandedToast(
    onClose: toast.dismiss,
  ),
);
```

## 🔁 Coming from fluttertoast?

| fluttertoast | butter_toast |
|---|---|
| `Fluttertoast.showToast(msg: 'Hi')` | `ButterToast.show('Hi')` |
| `gravity: ToastGravity.TOP` | `position: ButterToastPosition.topCenter` |
| `toastLength: Toast.LENGTH_LONG` | `duration: Duration(seconds: 4)` |
| `Fluttertoast.cancel()` | `ButterToast.dismissAll()` |
| Cut to 2 lines on Android 11+ | ✅ Full text, with Show more |

## 📱 Platforms

| Android | iOS | Web |
|:---:|:---:|:---:|
| ✅ | ✅ | ✅ |

Drawn in Flutter, so it looks the same everywhere. A small native part
only reads the app icon for `ButterToastAppIcon`. Tested on a Galaxy A36
(Android 17); iOS and web haven't been tested on a device yet.

## 🤝 Contributing

Bugs, ideas and pull requests are welcome in the
[issue tracker](https://github.com/parthbhensdadiya226/butter_toast/issues).
If butter_toast made your app a little smoother, a 👍 on
[pub.dev](https://pub.dev/packages/butter_toast) helps others find it.

## 📄 License

MIT © Parth Bhensdadiya
