# butter_toast example

A playground for [butter_toast](https://pub.dev/packages/butter_toast):
pick a style and a position, then try every toast type, a promise toast, a
long message, a custom toast, the keyboard and a dialog.

```bash
flutter run --release
```

The whole setup is one line in `MaterialApp`:

```dart
MaterialApp(
  builder: ButterToast.init(),
  home: const HomePage(),
);

ButterToast.success('Event created', description: 'Sunday, 9:00 AM');
```
