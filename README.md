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

<img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/hero.gif" width="280" alt="Card toasts with Retry and Undo buttons stacking, spreading out and one swiped away">

</div>

> **New in 0.2.0:** Undo / Retry buttons on toasts, a close **×**,
> `onDismiss` with the reason, and dismiss by tag.
> [See the changelog →](CHANGELOG.md)

---

## 📚 Contents

- [Why butter_toast?](#-why-butter_toast)
- [See it move](#-see-it-move)
- [Quick start](#-quick-start)
- [Showing toasts: `show` and the shortcuts](#-showing-toasts-show-and-the-shortcuts)
- [All parameters](#-all-parameters)
- [Updating and dismissing a toast](#-updating-and-dismissing-a-toast)
- [Action buttons, close button and onDismiss](#-action-buttons-close-button-and-ondismiss)
- [Promise toasts](#-promise-toasts)
- [Positions](#-positions)
- [Pill or card](#-pill-or-card)
- [Swipe to dismiss](#-swipe-to-dismiss)
- [Repeated taps and tags](#-repeated-taps-and-tags)
- [Icons and the app icon](#%EF%B8%8F-icons-and-the-app-icon)
- [Theming: app-wide and per toast](#-theming-app-wide-and-per-toast)
- [Dialogs and bottom sheets](#-dialogs-and-bottom-sheets)
- [Long text, keyboard and safe area](#-long-text-keyboard-and-safe-area)
- [Fully custom toasts](#-fully-custom-toasts)
- [Coming from fluttertoast?](#-coming-from-fluttertoast)
- [Platforms](#-platforms)

## ✨ Why butter_toast?

`fluttertoast` shows the native Android toast. Since Android 11 the system
cuts that toast to **two lines**, ignores your position and blocks custom
layouts. Most Flutter alternatives fix that by drawing a wide **snackbar**.
butter_toast draws a real **toast**: small, light, and out of your way.

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
| 🔘 **Action buttons** | **Undo**, **Retry** or **Cancel** on a toast, an optional close **×**, and `onDismiss` tells you why it left |
| 🧹 **No pile-ups** | Tap a button 10 times, see **1** toast; a `tag` updates a toast in place |
| 🧵 **No context needed** | Call it from blocs, services or a Dio interceptor |
| 🎨 **Themeable** | App-wide with a `ThemeExtension`, or per toast with `theme:` |
| ♿ **Accessible** | TalkBack and VoiceOver read toasts out; reduced motion fades instead of sliding |
| 📦 **Zero dependencies** | Only the Flutter SDK |

## 🎬 See it move

| Swipe any toast, any direction | Corners slide in from the side | Promise: loading → success |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/swipe.gif" width="220" alt="Toasts in a spread stack swiped away diagonally, up and sideways, starting with the middle one"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/positions.gif" width="220" alt="Card toasts sliding in from each corner"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/promise.gif" width="220" alt="A loading pill turning into a success pill"> |

| Pill | Card | Long message |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/pill.png" width="220" alt="Pill toast"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/card.png" width="220" alt="Card toast with description"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/long.png" width="220" alt="Long message collapsed behind Show more"> |

| Undo, Retry and close **×** | 5 taps, 1 toast |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/actions.png" width="220" alt="Three card toasts: one with a close button, one with Retry and one with Undo"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/signup.gif" width="250" alt="Tapping Sign up five times shows one toast, which goes away when the terms box is ticked"> |

## 🚀 Quick start

**1. Add the package**

```yaml
dependencies:
  butter_toast: ^0.2.0
```

**2. Add the toast layer to your app, once**

```dart
import 'package:butter_toast/butter_toast.dart';

MaterialApp(
  builder: ButterToast.init(), // 👈 that's it
  home: const HomePage(),
);
```

`ButterToast.init()` puts the toasts above the `Navigator`, so they show on
every screen, dialog and bottom sheet. Already using `builder`? Chain them:

```dart
builder: (context, child) => ButterToast.init()(context, MyWrapper(child)),
```

**3. Toast from anywhere**

```dart
ButterToast.show('Copied to clipboard');
```

No `BuildContext`, so it works from widgets, blocs, services and
interceptors alike.

## 🍞 Showing toasts: `show` and the shortcuts

There's **one** method that does everything, `ButterToast.show`. You choose
what the toast is about with the `type` enum:

```dart
ButterToast.show('Event created', type: ButterToastType.success);
ButterToast.show("Couldn't send", type: ButterToastType.error);
```

For everyday code there are **shortcuts** that fill in the type for you.
They take the same parameters as `show`, so use whichever reads better:

| Shortcut | Same as | Looks like |
|---|---|---|
| `ButterToast.show('Hi')` | `type: ButterToastType.normal` | No icon (or your theme `icon`) |
| `ButterToast.success('Saved')` | `type: ButterToastType.success` | ✅ green check |
| `ButterToast.error('Failed')` | `type: ButterToastType.error` | ⛔ red icon |
| `ButterToast.warning('Low storage')` | `type: ButterToastType.warning` | ⚠️ amber icon |
| `ButterToast.info('New version')` | `type: ButterToastType.info` | ℹ️ blue icon |
| `ButterToast.loading('Saving…')` | `type: ButterToastType.loading` | 🔄 spinner, stays until updated or dismissed |

**Which one should I use?**

- Use a **shortcut** when you know the type while writing the code. It's
  shorter and reads like a sentence:

  ```dart
  ButterToast.success('Profile saved', description: 'Changes are live.');
  ```

- Use **`show` with `type`** when the type comes from data, like an API
  result, so you don't need an `if` for every case:

  ```dart
  ButterToast.show(
    result.message,
    type: result.ok ? ButterToastType.success : ButterToastType.error,
  );
  ```

Both return a `ButterToastHandle` you can use to
[update or dismiss](#-updating-and-dismissing-a-toast) the toast later.

## 🧾 All parameters

Every parameter except the message is optional. Anything you leave out
comes from the [theme](#-theming-app-wide-and-per-toast).

```dart
ButterToast.show(
  'Payment received',                        // main text (the title on a card)
  description: '₹1,200 from Sam',            // quieter second line
  type: ButterToastType.success,             // icon and its colour
  style: ButterToastStyle.card,              // pill or card
  position: ButterToastPosition.topCenter,   // one of 7 positions
  duration: const Duration(seconds: 6),      // Duration.zero = until dismissed
  icon: const Icon(Icons.payments),          // replaces the type icon
  showIcon: true,                            // false hides the icon
  onTap: () => openPayments(),               // called when tapped
  dismissible: true,                         // false turns off swiping
  tag: 'payment',                            // same tag updates this toast
  theme: const ButterToastTheme(...),        // style for this toast only
  action: ButterToastAction('View', onPressed: openPayments), // a button
  onDismiss: (reason) => log(reason),        // called once when it leaves
  showCloseButton: true,                     // a close ×
);
```

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `message` | `String` | required | The main text. On a card it's the title. |
| `description` | `String?` | none | A second, quieter line. |
| `type` | `ButterToastType` | `normal` | Picks the icon and its colour. Only on `show`; the shortcuts set it for you. |
| `style` | `ButterToastStyle?` | theme (`pill`) | `pill` or `card`. |
| `position` | `ButterToastPosition?` | theme (`bottomCenter`) | Where it appears. See [Positions](#-positions). |
| `duration` | `Duration?` | theme (4 s) | How long it stays. `Duration.zero` keeps it until dismissed. Not on `loading`. |
| `icon` | `Widget?` | type icon | Replaces the icon for this toast. |
| `showIcon` | `bool` | `true` | `false` shows no icon at all. |
| `onTap` | `VoidCallback?` | none | Called when the toast is tapped. |
| `dismissible` | `bool` | `true` (`false` for `loading`) | Whether it can be swiped away. |
| `tag` | `String?` | none | A toast with the same tag replaces this one in place. |
| `theme` | `ButterToastTheme?` | none | Theme for this toast only. See [Per toast](#per-toast). |
| `action` | `ButterToastAction?` | none | A button such as "Undo". See [Action buttons](#-action-buttons-close-button-and-ondismiss). |
| `onDismiss` | `ValueChanged<ButterToastDismissReason>?` | none | Called once when the toast starts to leave, with the reason. |
| `showCloseButton` | `bool?` | theme (`false`) | Shows a close **×**. |

## 🔄 Updating and dismissing a toast

Every call returns a `ButterToastHandle`:

```dart
final toast = ButterToast.loading('Syncing…');

// later
toast.update(message: 'All synced', type: ButterToastType.success);
// or
toast.dismiss();

toast.isActive; // false once it has left the screen
```

`update` morphs the same toast smoothly, and restarts its timer when it
turns from `loading` into anything else.

No handle at hand? Dismiss by tag, or clear the screen:

```dart
ButterToast.dismiss(tag: 'signup'); // every toast shown with this tag
ButterToast.dismissAll();           // every toast
```

## 🔘 Action buttons, close button and onDismiss

### Action button

Give a toast one button, such as **Undo** or **Retry**:

```dart
ButterToast.show(
  'Message deleted',
  action: ButterToastAction('Undo', onPressed: () => restore(message)),
);
```

Pressing it calls `onPressed` and dismisses the toast. To keep the toast on
screen, pass `dismissOnPress: false`. The button uses the toast's colours,
swapped: dark on a light card, light on a dark pill.

A loading toast can carry one too, for example to stop an upload:

```dart
final upload = ButterToast.loading(
  'Uploading video…',
  action: ButterToastAction('Cancel', onPressed: task.cancel),
);
```

### Close button

Phones can swipe toasts away, but on desktop and the web a close **×** is
easier to find. Turn it on for one toast, or for all of them in the theme:

```dart
ButterToast.info(
  'Stays until you close it',
  duration: Duration.zero,
  showCloseButton: true,
);

ButterToastTheme(showCloseButton: true) // every toast
```

`showCloseButton: false` on a call hides it again for that toast.

### onDismiss: know why a toast left

`onDismiss` is called **once**, as the toast starts to leave, with a
`ButterToastDismissReason`:

| Reason | When |
|---|---|
| `timeout` | Its duration ran out |
| `swipe` | Someone swiped it away |
| `action` | Its action button was pressed |
| `closeButton` | Its close **×** was pressed |
| `programmatic` | Your code dismissed it: `handle.dismiss()`, `ButterToast.dismiss(tag:)` or `dismissAll()` |
| `replaced` | A new toast with the same `tag` took its place |
| `limit` | Too many toasts at its position, so the oldest left |

That makes the classic **"delete with Undo"** easy. Hide the item right
away, and only delete it for real if the toast leaves without Undo:

```dart
void delete(Note note) {
  notes.hide(note);
  ButterToast.show(
    'Note deleted',
    action: ButterToastAction('Undo', onPressed: () => notes.show(note)),
    onDismiss: (reason) {
      if (reason != ButterToastDismissReason.action) notes.delete(note);
    },
  );
}
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

It returns the future's result. If the future fails, the error toast shows
and the error is rethrown, so your own `try`/`catch` still works.
`promise` also takes `style`, `position`, `tag` and `theme`.

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

A toast keeps its position for its whole life, even if the default changes
while it's on screen.

## 🃏 Pill or card

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
- **Card** shows a title and description at full width. Several cards
  stack like a deck; **tap** (or hover on web) to spread them out.

While a stack is spread out, its timers pause so nothing disappears while
you read. It closes again when you **tap anywhere else**, or on its own
after **5 seconds** without a touch, and then the toasts leave as usual.

## 👆 Swipe to dismiss

Throw a toast **in any direction** to dismiss it: up, down, sideways or
diagonally. A short drag springs back. In a spread-out stack every toast
can be swiped on its own, including the ones in the middle. Pass
`dismissible: false` to turn swiping off for a toast.

## 🧹 Repeated taps and tags

A sign-up button that warns about the terms is a good example. The user
taps **Sign up** ten times without ticking the box:

```dart
void signUp() {
  if (!acceptedTerms) {
    ButterToast.error('Please accept the terms');
    return;
  }
  // …
}
```

With the native toast you'd get ten toasts in a queue, one after another.
With butter_toast you get **one**, and no `tag` is needed:

<p align="center">
  <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/signup.gif" width="300" alt="Tapping Sign up five times shows one toast, which goes away when the terms box is ticked">
</p>

1. Before adding a toast, butter_toast looks at the toasts on screen.
2. If one at the same position shows the **same thing** (same message,
   description, type, style and theme), no copy is added.
3. That toast's timer **starts again** instead, so it stays up while the
   user keeps tapping and leaves a few seconds after the **last** tap.

### When you need a tag

Content matching only works when the text is the same. When the message
changes, for example a form that checks one field after another, give the
toasts a `tag`. A new toast with the same tag **replaces the one on screen
in place**, with a smooth morph:

```dart
ButterToast.error('Enter your email', tag: 'signup');
ButterToast.error('Please accept the terms', tag: 'signup'); // same toast
```

Once the user fixes the problem, take the toast away by its tag:

```dart
onChanged: (accepted) {
  if (accepted) ButterToast.dismiss(tag: 'signup');
}
```

The same works for progress:

```dart
ButterToast.loading('Saving…', tag: 'save');
ButterToast.success('Saved', tag: 'save'); // same toast, now a success
```

| Situation | Tag needed? |
|---|---|
| The same message, tapped many times | ❌ No, it's automatic |
| Different messages from one form or button | ✅ Yes, one toast whose text changes |
| Removing a toast without keeping its handle | ✅ Yes, `ButterToast.dismiss(tag: …)` |
| Loading → done | Either a tag, or `handle.update()` |

### What never merges

- Toasts with an `action` or `onDismiss`, because each one has its own
  callbacks. Two "File deleted · Undo" toasts must each undo their own file.
- Anything at all, once you turn merging off. Some apps want every tap to
  show, like a "+1" counter:

```dart
// App-wide
ButterToastTheme(mergeDuplicates: false)

// Or for one kind of toast
ButterToast.show('+1', theme: const ButterToastTheme(mergeDuplicates: false));
```

## 🖼️ Icons and the app icon

By default, typed toasts show their own icon and plain `show` toasts show
none. You can change that at three levels:

| I want to… | Do this |
|---|---|
| Change the icon of **one toast** | `icon: const Icon(Icons.wifi_off)` |
| Hide the icon on **one toast** | `showIcon: false` |
| Give **plain toasts** an icon everywhere | `ButterToastTheme(icon: ...)` |
| Use one icon on **every toast** | `ButterToastTheme(icon: ..., typeIcons: false)` |

`ButterToastAppIcon` shows your app's **launcher icon**, the way Android
shows it on native toasts. It's read from the platform at run time, so it
always matches the icon on the home screen, with no asset to add or keep in
sync:

```dart
// App-wide
ButterToastTheme(
  icon: ButterToastAppIcon(), // plain toasts show the app icon
  typeIcons: false,           // success, error, … show it too
)

// Or just on one toast
ButterToast.success('Order placed', icon: const ButterToastAppIcon());
```

<p align="center">
  <img src="https://raw.githubusercontent.com/parthbhensdadiya226/butter_toast/main/doc/app_icon.png" width="280" alt="Three toasts showing the app's launcher icon instead of type icons">
</p>

| Platform | Icon used |
|---|---|
| Android | The launcher icon, shown round like the launcher does |
| iOS | The app icon from `Info.plist`, with rounded corners |
| Web | The icon from your web app manifest, with rounded corners |

Any widget works as an icon, such as `Image.asset('assets/logo.png')`.

<details>
<summary><b>How the app icon works on the web</b></summary>

A web app has no launcher to ask, so butter_toast uses the same icon the
browser uses when someone installs your app:

1. `flutter build web` copies your `web` folder into `build/web`, so
   `web/manifest.json` and `web/icons/…` are served next to your app.
2. `ButterToastAppIcon` finds the manifest through the
   `<link rel="manifest">` tag in `web/index.html` and reads its `icons`
   list.
3. It picks a regular icon (not a `maskable` one, which is made to be
   cropped), the smallest that's at least 96 px, and loads it like any image
   on your site.
4. If there's no manifest, it has no icons, or the icon fails to load, it
   uses `icons/Icon-192.png`. If that's missing too, the toast shows no icon.

The lookup happens once, and the result is reused. Since it follows your
manifest, changing the icons there (by hand or with
`flutter_launcher_icons`) changes the toast icon too, even if you move them
to another folder. Paths are relative to the manifest, so apps served from a
sub-folder work as well.

</details>

## 🎨 Theming: app-wide and per toast

### App-wide

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

Not using `ThemeData` extensions? Pass it to init instead:
`ButterToast.init(theme: const ButterToastTheme(...))`.

### Per toast

Want a different look on one screen or for one kind of message, like a dark
checkout toast with your app icon? Pass `theme:` to that call. Set only the
fields you want to change; everything else still comes from the app theme.

```dart
const checkoutToast = ButterToastTheme(
  style: ButterToastStyle.card,
  cardColor: Color(0xFF0F172A),
  cardForegroundColor: Colors.white,
  cardBorderColor: Color(0xFF1E293B),
  icon: ButterToastAppIcon(),
  typeIcons: false,
);

ButterToast.success('Payment done', theme: checkoutToast);
ButterToast.error('Card declined', theme: checkoutToast);
```

Keep the theme in a `const` and reuse it on every toast of that screen.
Only the toasts you pass it to change; other toasts keep the app look.

A per-toast theme applies its colours, text style, shadows, radius, icons,
`maxLines`, `style`, `position`, `duration`, `showCloseButton` and
`mergeDuplicates`. Settings that shape the
whole stack at a position (`margin`, `maxWidth`, `gap`, `bottomOffset`,
`visibleCount`, `maxToasts`, `maxHeightFraction`) stay app-wide.

### Which setting wins?

From strongest to weakest:

1. A parameter on the call, such as `position:` or `icon:`
2. The call's `theme:`
3. `ButterToast.init(theme: ...)`
4. The `ButterToastTheme` in your `ThemeData.extensions`
5. The built-in defaults

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
| `showCloseButton` | `false` | Shows a close **×** on toasts |
| `mergeDuplicates` | `true` | `false` lets identical toasts show side by side |

</details>

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

## 🧩 Fully custom toasts

Draw anything; butter_toast still animates, stacks, times, positions and
swipes it:

```dart
ButterToast.custom(
  builder: (context, toast) => MyBrandedToast(
    onClose: toast.dismiss,
  ),
  position: ButterToastPosition.topCenter,
);
```

## 🔁 Coming from fluttertoast?

| fluttertoast | butter_toast |
|---|---|
| `Fluttertoast.showToast(msg: 'Hi')` | `ButterToast.show('Hi')` |
| `gravity: ToastGravity.TOP` | `position: ButterToastPosition.topCenter` |
| `toastLength: Toast.LENGTH_SHORT` | `duration: Duration(seconds: 2)` |
| `toastLength: Toast.LENGTH_LONG` | `duration: Duration(milliseconds: 3500)` |
| `Fluttertoast.cancel()` | `ButterToast.dismissAll()` |
| 10 taps = 10 toasts in a queue | 10 taps = 1 toast ([why](#-repeated-taps-and-tags)) |

## 📱 Platforms

| Android | iOS | Web |
|:---:|:---:|:---:|
| ✅ | ✅ | ✅ |

Drawn in Flutter, so it looks the same everywhere. A small native part
only reads the app icon for `ButterToastAppIcon`. Tested on a Galaxy A36
(Android 17) and on the web (Chromium); iOS hasn't been tested on a device
yet.

## 🤝 Contributing

Bugs, ideas and pull requests are welcome in the
[issue tracker](https://github.com/parthbhensdadiya226/butter_toast/issues).
If butter_toast made your app a little smoother, a 👍 on
[pub.dev](https://pub.dev/packages/butter_toast) helps others find it.

## 📄 License

MIT © Parth Bhensdadiya
