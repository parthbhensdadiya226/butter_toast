import 'package:butter_toast/butter_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({ButterToastTheme? theme}) => MaterialApp(
  builder: ButterToast.init(theme: theme),
  home: const Scaffold(body: SizedBox.expand()),
);

void main() {
  testWidgets('shows a toast and removes it after its duration', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    ButterToast.show('Saved', duration: const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('each type shows its icon', (tester) async {
    await tester.pumpWidget(_app());
    ButterToast.success('Done');
    ButterToast.error('Failed');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('the same toast twice is shown once', (tester) async {
    await tester.pumpWidget(_app());
    final a = ButterToast.show('Copied');
    final b = ButterToast.show('Copied');
    await tester.pumpAndSettle();
    expect(a, b);
    expect(find.text('Copied'), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('promise turns loading into success in the same toast', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    final done = ButterToast.promise(
      Future<int>.delayed(const Duration(seconds: 1), () => 3),
      loading: 'Uploading…',
      success: (n) => '$n files uploaded',
      error: (_) => 'Upload failed',
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Uploading…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(await done, 3);
    expect(find.text('3 files uploaded'), findsOneWidget);
    expect(find.text('Uploading…'), findsNothing);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('promise shows the error and rethrows', (tester) async {
    await tester.pumpWidget(_app());
    Object? caught;
    ButterToast.promise<void>(
      Future<void>.delayed(
        const Duration(milliseconds: 200),
        () => throw StateError('offline'),
      ),
      loading: 'Sending…',
      success: (_) => 'Sent',
      error: (_) => "Couldn't send",
    ).catchError((Object e) => caught = e);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(caught, isA<StateError>());
    expect(find.text("Couldn't send"), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('keeps at most maxToasts per position', (tester) async {
    await tester.pumpWidget(_app(theme: const ButterToastTheme(maxToasts: 3)));
    for (var i = 0; i < 6; i++) {
      ButterToast.show('Toast $i', duration: Duration.zero);
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('Toast'), findsNWidgets(3));
    expect(find.text('Toast 5'), findsOneWidget);
    expect(find.text('Toast 0'), findsNothing);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('a centre toast replaces the previous one', (tester) async {
    await tester.pumpWidget(_app());
    ButterToast.show('First', position: ButterToastPosition.center);
    await tester.pumpAndSettle();
    ButterToast.show('Second', position: ButterToastPosition.center);
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('long text collapses behind Show more and pauses when open', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    final long = List.filled(40, 'word').join(' ');
    ButterToast.show(long, duration: const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Show more'), findsOneWidget);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);

    // The timer is paused while the full text is open.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('stays inside the safe area and above the keyboard', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(top: 40, bottom: 30)
      ..viewPadding = const FakeViewPadding(top: 40, bottom: 30)
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    ButterToast.show(List.filled(60, 'long').join(' '));
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(Text).first);
    expect(rect.bottom, lessThanOrEqualTo(800 - 300));
    expect(rect.top, greaterThanOrEqualTo(40));
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('a bottom toast can be swiped down to dismiss', (tester) async {
    await tester.pumpWidget(_app());
    ButterToast.show('Swipe me', duration: Duration.zero);
    await tester.pumpAndSettle();
    await tester.fling(find.text('Swipe me'), const Offset(0, 200), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Swipe me'), findsNothing);
  });

  testWidgets('a toast can be swiped away in any direction', (tester) async {
    await tester.pumpWidget(_app());
    for (final (i, fling) in const [
      Offset(0, -200),
      Offset(0, 200),
      Offset(-300, 0),
      Offset(300, 0),
    ].indexed) {
      ButterToast.show(
        'Swipe $i',
        position: ButterToastPosition.topRight,
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();
      await tester.fling(find.text('Swipe $i'), fling, 1500);
      await tester.pumpAndSettle();
      expect(find.text('Swipe $i'), findsNothing, reason: 'fling $fling');
    }
  });

  testWidgets('a short drag springs back', (tester) async {
    await tester.pumpWidget(_app());
    ButterToast.show('Stay', duration: Duration.zero);
    await tester.pumpAndSettle();
    final before = tester.getRect(find.text('Stay'));
    await tester.drag(find.text('Stay'), const Offset(20, 0));
    await tester.pumpAndSettle();
    final after = tester.getRect(find.text('Stay'));
    expect(after.left, closeTo(before.left, 0.5));
    expect(after.top, closeTo(before.top, 0.5));
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('the middle toast of a spread stack can be swiped away', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(theme: const ButterToastTheme(style: ButterToastStyle.card)),
    );
    for (final text in ['One', 'Two', 'Three']) {
      ButterToast.show(text, duration: Duration.zero);
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('Three'));
    await tester.pumpAndSettle();

    await tester.fling(find.text('Two'), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsNothing);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('a spread stack closes on a tap outside and when idle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(theme: const ButterToastTheme(style: ButterToastStyle.card)),
    );
    ButterToast.show('A', duration: const Duration(seconds: 2));
    ButterToast.show('B', duration: const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final collapsed = tester.getRect(find.text('A'));

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('A')), isNot(collapsed));
    // Timers are paused while spread out.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('A'), findsOneWidget);

    await tester.tapAt(const Offset(20, 100));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('A')), collapsed);

    // Collapsed again, so the timers run and both leave.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);

    ButterToast.show('C', duration: Duration.zero);
    ButterToast.show('D', duration: Duration.zero);
    await tester.pumpAndSettle();
    final before = tester.getRect(find.text('C'));
    await tester.tap(find.text('D'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('C')), isNot(before));
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('C')), before);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('a tag replaces the toast instead of adding one', (tester) async {
    await tester.pumpWidget(_app());
    final a = ButterToast.loading('Saving…', tag: 'save');
    final b = ButterToast.loading('Saving…', tag: 'save');
    ButterToast.success('Saved', tag: 'save');
    await tester.pumpAndSettle();
    expect(a, b);
    expect(find.text('Saving…'), findsNothing);
    expect(find.text('Saved'), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('repeated loading toasts are merged', (tester) async {
    await tester.pumpWidget(_app());
    ButterToast.loading('Uploading…');
    ButterToast.loading('Uploading…');
    ButterToast.loading('Uploading…');
    // A spinner never settles, so wait a fixed time.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Uploading…'), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('theme icon replaces type icons, showIcon hides it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        theme: const ButterToastTheme(
          icon: Icon(Icons.favorite),
          typeIcons: false,
        ),
      ),
    );
    ButterToast.error('Failed');
    ButterToast.show('Plain', showIcon: false);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('a per-toast theme styles only that toast', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    const checkout = ButterToastTheme(
      position: ButterToastPosition.topCenter,
      pillForegroundColor: Color(0xFF00FF00),
      icon: Icon(Icons.favorite),
      typeIcons: false,
    );
    ButterToast.success('Paid', theme: checkout);
    ButterToast.success('Saved', position: ButterToastPosition.bottomLeft);
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('Paid')).dy, lessThan(400));
    final paid = tester.widget<Text>(find.text('Paid'));
    expect(paid.style?.color, const Color(0xFF00FF00));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    // The other toast keeps the app theme.
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('taps pass through empty space to the app', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        builder: ButterToast.init(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 200),
              child: TextButton(
                onPressed: () => tapped = true,
                child: const Text('Behind'),
              ),
            ),
          ),
        ),
      ),
    );
    ButterToast.show('Hi', duration: Duration.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Behind'));
    expect(tapped, isTrue);
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('a toast keeps its position when the default changes', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget app(ButterToastPosition position) => MaterialApp(
      builder: ButterToast.init(theme: ButterToastTheme(position: position)),
      home: const Scaffold(body: SizedBox.expand()),
    );
    await tester.pumpWidget(app(ButterToastPosition.bottomCenter));
    ButterToast.show('Stay', duration: Duration.zero);
    await tester.pumpAndSettle();
    final before = tester.getRect(find.text('Stay'));

    await tester.pumpWidget(app(ButterToastPosition.topCenter));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Stay')), before);
    expect(before.center.dy, greaterThan(400));
    ButterToast.dismissAll();
    await tester.pumpAndSettle();
  });

  test('showing a toast without a toaster explains the fix', () {
    expect(
      () => ButterToast.show('No host'),
      throwsA(
        isA<FlutterError>().having(
          (e) => e.toString(),
          'message',
          contains('ButterToast.init()'),
        ),
      ),
    );
  });

  test('theme merge and lerp', () {
    const a = ButterToastTheme(maxWidth: 300, style: ButterToastStyle.card);
    const b = ButterToastTheme(maxWidth: 500, margin: 20);
    final merged = a.merge(b);
    expect(merged.maxWidth, 300);
    expect(merged.margin, 20);
    expect(merged.style, ButterToastStyle.card);
    expect(a.lerp(b, 0.5).maxWidth, 400);
  });
}
