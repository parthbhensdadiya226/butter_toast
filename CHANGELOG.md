## 0.2.1

* Added a Buy Me a Coffee link (`funding` in pubspec and a Support section in the README).

## 0.2.0

* **Action buttons:** `action: ButterToastAction('Undo', onPressed: ...)` adds
  a button to a toast. Pressing it dismisses the toast unless
  `dismissOnPress` is false. Works on loading toasts too, for a Cancel.
* **`onDismiss`** is called once when a toast starts to leave, with a
  `ButterToastDismissReason`: `timeout`, `swipe`, `action`, `closeButton`,
  `programmatic`, `replaced` or `limit`.
* **Close button:** `showCloseButton: true` on a toast, or
  `ButterToastTheme(showCloseButton: true)` for all of them.
* **`ButterToast.dismiss(tag: ...)`** dismisses toasts by their tag.
* **`ButterToastTheme.mergeDuplicates`:** set it to false to let identical
  toasts show side by side. Toasts with an action or `onDismiss` are never
  merged, since each has its own callbacks.
* **VoiceOver reads toasts on iOS.** The toast's live region now carries its
  text as its label, which iOS needs in order to announce it. Buttons on a
  toast stay separate, focusable elements.

## 0.1.0

* 🎉 Initial release.
* `ButterToast.show`, `success`, `error`, `warning`, `info` and `loading`,
  callable from anywhere once `ButterToast.init()` is added to the app.
* Two styles: a compact **pill** and a Sonner-style **card** that stacks and
  spreads out on tap or hover.
* Seven positions, each with its own motion: top and bottom slide from their
  edge, corners slide in from the side, centre scales in.
* Spring animations, swipe to dismiss in any direction (even a toast in the
  middle of a spread-out stack), and smooth morphing when a toast updates.
* A spread-out stack pauses its timers and closes again on a tap outside or
  after 5 seconds without a touch.
* Repeated identical toasts merge; a `tag` updates a toast in place.
* `ButterToastAppIcon` shows the app's launcher icon, read at run time (on
  the web, from the web app manifest); `icon`, `typeIcons` and `showIcon`
  control toast icons.
* `ButterToast.promise` turns one toast from loading into success or error.
* Height budget with "Show more" for long text; keeps clear of the safe area
  and the keyboard, and shows above dialogs and bottom sheets.
* `ButterToastTheme` as a `ThemeExtension`, a `theme:` parameter to style a
  single toast, and `ButterToast.custom` for fully custom toasts.
