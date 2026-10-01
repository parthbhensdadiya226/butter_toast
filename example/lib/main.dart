import 'package:butter_toast/butter_toast.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ToastDemoApp());

class ToastDemoApp extends StatefulWidget {
  const ToastDemoApp({super.key});

  @override
  State<ToastDemoApp> createState() => _ToastDemoAppState();
}

class _ToastDemoAppState extends State<ToastDemoApp> {
  ButterToastStyle _style = ButterToastStyle.card;
  ButterToastPosition _position = ButterToastPosition.bottomCenter;
  bool _dark = false;
  bool _appIcon = false;

  @override
  Widget build(BuildContext context) {
    // The toast theme lives in the app theme, like any other extension.
    final toastTheme = ButterToastTheme(
      style: _style,
      position: _position,
      // The launcher icon on every toast, instead of the type icons.
      icon: _appIcon ? const ButterToastAppIcon() : null,
      typeIcons: !_appIcon,
    );
    ThemeData theme(Brightness brightness) => ThemeData(
      colorSchemeSeed: const Color(0xFFF2B33D),
      brightness: brightness,
      extensions: [toastTheme],
    );

    return MaterialApp(
      title: 'butter_toast',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      // One line to enable toasts everywhere, above dialogs and sheets.
      builder: ButterToast.init(),
      home: DemoPage(
        style: _style,
        position: _position,
        dark: _dark,
        appIcon: _appIcon,
        onAppIcon: (v) => setState(() => _appIcon = v),
        onStyle: (s) => setState(() => _style = s),
        onPosition: (p) => setState(() => _position = p),
        onDark: (d) => setState(() => _dark = d),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({
    super.key,
    required this.style,
    required this.position,
    required this.dark,
    required this.appIcon,
    required this.onAppIcon,
    required this.onStyle,
    required this.onPosition,
    required this.onDark,
  });

  final ButterToastStyle style;
  final ButterToastPosition position;
  final bool dark;
  final bool appIcon;
  final ValueChanged<bool> onAppIcon;
  final ValueChanged<ButterToastStyle> onStyle;
  final ValueChanged<ButterToastPosition> onPosition;
  final ValueChanged<bool> onDark;

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _message = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _promise() async {
    try {
      await ButterToast.promise(
        Future<int>.delayed(const Duration(seconds: 2), () => 12),
        loading: 'Uploading photos…',
        success: (count) => '$count photos uploaded',
        error: (_) => "Couldn't upload your photos",
      );
    } catch (_) {}
  }

  void _deleteNote() {
    ButterToast.show(
      'Note deleted',
      action: ButterToastAction(
        'Undo',
        onPressed: () => ButterToast.success('Note restored'),
      ),
      // Delete for real only if the toast left without Undo.
      onDismiss: (reason) {
        if (reason != ButterToastDismissReason.action) {
          debugPrint('Note deleted for good ($reason)');
        }
      },
    );
  }

  void _signUp() {
    if (!_acceptedTerms) {
      // Tapping again doesn't add more toasts; it keeps this one up.
      ButterToast.error('Please accept the terms', tag: 'signup');
      return;
    }
    ButterToast.success('Account created');
  }

  void _send() {
    final text = _message.text.trim();
    if (text.isEmpty) {
      ButterToast.warning('Write a message first');
      return;
    }
    _message.clear();
    ButterToast.success('Message sent', description: text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('butter_toast 🧈'),
        actions: [
          IconButton(
            tooltip: 'Dark mode',
            onPressed: () => widget.onDark(!widget.dark),
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _Section(
            title: 'Style',
            child: SegmentedButton<ButterToastStyle>(
              segments: const [
                ButtonSegment(
                  value: ButterToastStyle.pill,
                  label: Text('Pill'),
                  icon: Icon(Icons.horizontal_rule_rounded),
                ),
                ButtonSegment(
                  value: ButterToastStyle.card,
                  label: Text('Card'),
                  icon: Icon(Icons.layers_rounded),
                ),
              ],
              selected: {widget.style},
              onSelectionChanged: (s) => widget.onStyle(s.first),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('App icon on every toast'),
            subtitle: const Text('Read from the launcher, no asset needed'),
            value: widget.appIcon,
            onChanged: widget.onAppIcon,
          ),
          _Section(
            title: 'Position',
            child: _PositionPicker(
              value: widget.position,
              onChanged: widget.onPosition,
            ),
          ),
          _Section(
            title: 'Try it',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.success(
                    'Event created',
                    description: 'Sunday, 9:00 AM',
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Success'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.error(
                    "Couldn't send",
                    description: 'Check your connection and try again.',
                  ),
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Error'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.warning('Storage almost full'),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Warning'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.info('New version available'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Info'),
                ),
                FilledButton.tonal(
                  onPressed: () => ButterToast.show('Copied to clipboard'),
                  child: const Text('Plain'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _promise,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Promise'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.info(
                    'Upload paused',
                    description:
                        "We couldn't upload photo.jpg because your "
                        'connection dropped. We will try again as soon as '
                        "you're back online, so you can keep using the app. "
                        'Your other files are safe and will upload in order.',
                  ),
                  icon: const Icon(Icons.notes_rounded),
                  label: const Text('Long message'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.custom(
                    builder: (context, toast) => _CustomToast(toast: toast),
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Custom'),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Buttons on toasts',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _deleteNote,
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Undo'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.error(
                    "You're offline",
                    duration: Duration.zero,
                    tag: 'offline',
                    action: ButterToastAction(
                      'Retry',
                      onPressed: () =>
                          ButterToast.success('Back online', tag: 'offline'),
                      // The success toast replaces this one through the tag.
                      dismissOnPress: false,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ButterToast.info(
                    'Stays until you close it',
                    duration: Duration.zero,
                    showCloseButton: true,
                  ),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Close button'),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Sign-up form',
            child: Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                    // The error is fixed, so take its toast away.
                    if (_acceptedTerms) ButterToast.dismiss(tag: 'signup');
                  },
                ),
                const Expanded(child: Text('I accept the terms')),
                FilledButton(onPressed: _signUp, child: const Text('Sign up')),
              ],
            ),
          ),
          _Section(
            title: 'Real life',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _message,
                  decoration: InputDecoration(
                    hintText: 'Type a message, then send',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete note?'),
                          content: const Text('Toasts show above dialogs.'),
                          actions: [
                            TextButton(
                              onPressed: () => ButterToast.info(
                                'Still here, above the dialog',
                              ),
                              child: const Text('Toast'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text('Over a dialog'),
                    ),
                    OutlinedButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (context) => const _SheetDemo(),
                      ),
                      child: const Text('Over a bottom sheet'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        for (final text in [
                          'Photo saved',
                          'Added to album',
                          'Shared with Sam',
                        ]) {
                          ButterToast.success(text);
                        }
                      },
                      child: const Text('Stack of three'),
                    ),
                    OutlinedButton(
                      onPressed: ButterToast.dismissAll,
                      child: const Text('Dismiss all'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tap a card stack to spread it out; tap outside to close it. '
              'Swipe any toast in any direction to dismiss it.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDemo extends StatelessWidget {
  const _SheetDemo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Share photo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Toasts show above the sheet. A bottom toast floats over the '
            "sheet's lower edge; use the top position to keep the sheet clear.",
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ButterToast.success('Link copied'),
            child: const Text('Toast at the bottom'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => ButterToast.success(
              'Link copied',
              position: ButterToastPosition.topCenter,
            ),
            child: const Text('Toast at the top'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PositionPicker extends StatelessWidget {
  const _PositionPicker({required this.value, required this.onChanged});

  final ButterToastPosition value;
  final ValueChanged<ButterToastPosition> onChanged;

  static const _grid = [
    [
      ButterToastPosition.topLeft,
      ButterToastPosition.topCenter,
      ButterToastPosition.topRight,
    ],
    [null, ButterToastPosition.center, null],
    [
      ButterToastPosition.bottomLeft,
      ButterToastPosition.bottomCenter,
      ButterToastPosition.bottomRight,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 2.2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            for (final row in _grid)
              Expanded(
                child: Row(
                  children: [
                    for (final position in row)
                      Expanded(
                        child: position == null
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(4),
                                child: ChoiceChip(
                                  label: Text(_label(position)),
                                  selected: value == position,
                                  onSelected: (_) => onChanged(position),
                                ),
                              ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _label(ButterToastPosition p) => switch (p) {
    ButterToastPosition.topLeft => 'Top left',
    ButterToastPosition.topCenter => 'Top',
    ButterToastPosition.topRight => 'Top right',
    ButterToastPosition.center => 'Center',
    ButterToastPosition.bottomLeft => 'Bottom left',
    ButterToastPosition.bottomCenter => 'Bottom',
    ButterToastPosition.bottomRight => 'Bottom right',
  };
}

/// A fully custom toast: the package still animates, stacks and times it.
class _CustomToast extends StatelessWidget {
  const _CustomToast({required this.toast});

  final ButterToastHandle toast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF2B33D), Color(0xFFEF7C45)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧈', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Smooth as butter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: toast.dismiss,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Nice'),
          ),
        ],
      ),
    );
  }
}
