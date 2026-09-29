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
* `ButterToastAppIcon` shows the app's launcher icon, read at run time;
  `icon`, `typeIcons` and `showIcon` control toast icons.
* `ButterToast.promise` turns one toast from loading into success or error.
* Height budget with "Show more" for long text; keeps clear of the safe area
  and the keyboard, and shows above dialogs and bottom sheets.
* `ButterToastTheme` as a `ThemeExtension`, plus `ButterToast.custom` for
  fully custom toasts.
