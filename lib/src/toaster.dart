import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'item.dart';
import 'theme.dart';
import 'types.dart';

/// Show toasts from anywhere, without a `BuildContext`.
///
/// Add [ButterToast.init] to your app once:
///
/// ```dart
/// MaterialApp(builder: ButterToast.init(), home: const HomePage())
/// ```
///
/// Then call [show], [success], [error] and friends from widgets, blocs,
/// services or interceptors.
abstract final class ButterToast {
  static final List<ButterToastController> _hosts = [];

  static ButterToastController get _controller {
    if (_hosts.isEmpty) {
      throw FlutterError.fromParts([
        ErrorSummary('No ButterToaster found.'),
        ErrorHint(
          'Add `builder: ButterToast.init()` to your MaterialApp (or wrap '
          'your app in a ButterToaster) before showing toasts.',
        ),
      ]);
    }
    return _hosts.last;
  }

  /// A `MaterialApp.builder` that adds the toast layer above every route,
  /// dialog and bottom sheet.
  ///
  /// To combine it with another builder, call the result yourself:
  /// `builder: (context, child) => ButterToast.init()(context, MyWrapper(child))`.
  static TransitionBuilder init({ButterToastTheme? theme}) =>
      (context, child) =>
          ButterToaster(theme: theme, child: child ?? const SizedBox.shrink());

  /// Shows a toast with [message] and returns its handle.
  ///
  /// [description] adds a second, quieter line. [style], [position] and
  /// [duration] override the theme for this toast; a [duration] of
  /// [Duration.zero] keeps it until it is dismissed. [icon] replaces the
  /// default icon for [type]; [showIcon] false hides the icon. A [tag]
  /// makes the toast replace any toast on screen with the same tag, so
  /// repeated taps update one toast instead of adding more.
  ///
  /// [theme] styles this toast only. It is laid over the app's toast theme,
  /// so set just the fields you want to change. Its colours, text, shadows,
  /// icon, `maxLines`, `style`, `position` and `duration` apply; layout of
  /// the whole stack (margins, width, gap, limits) stays app-wide.
  static ButterToastHandle show(
    String message, {
    String? description,
    ButterToastType type = ButterToastType.normal,
    ButterToastStyle? style,
    ButterToastPosition? position,
    Duration? duration,
    Widget? icon,
    VoidCallback? onTap,
    bool dismissible = true,
    String? tag,
    bool showIcon = true,
    ButterToastTheme? theme,
  }) => _controller.show(
    ToastData(
      message: message,
      description: description,
      type: type,
      style: style ?? theme?.style,
      position: position ?? theme?.position,
      duration: duration ?? theme?.duration,
      icon: icon,
      onTap: onTap,
      dismissible: dismissible,
      tag: tag,
      showIcon: showIcon,
      theme: theme,
    ),
  );

  /// Shows a [ButterToastType.success] toast. See [show].
  static ButterToastHandle success(
    String message, {
    String? description,
    ButterToastStyle? style,
    ButterToastPosition? position,
    Duration? duration,
    Widget? icon,
    VoidCallback? onTap,
    bool dismissible = true,
    String? tag,
    bool showIcon = true,
    ButterToastTheme? theme,
  }) => show(
    message,
    description: description,
    type: ButterToastType.success,
    style: style,
    position: position,
    duration: duration,
    icon: icon,
    onTap: onTap,
    dismissible: dismissible,
    tag: tag,
    showIcon: showIcon,
    theme: theme,
  );

  /// Shows a [ButterToastType.error] toast. See [show].
  static ButterToastHandle error(
    String message, {
    String? description,
    ButterToastStyle? style,
    ButterToastPosition? position,
    Duration? duration,
    Widget? icon,
    VoidCallback? onTap,
    bool dismissible = true,
    String? tag,
    bool showIcon = true,
    ButterToastTheme? theme,
  }) => show(
    message,
    description: description,
    type: ButterToastType.error,
    style: style,
    position: position,
    duration: duration,
    icon: icon,
    onTap: onTap,
    dismissible: dismissible,
    tag: tag,
    showIcon: showIcon,
    theme: theme,
  );

  /// Shows a [ButterToastType.warning] toast. See [show].
  static ButterToastHandle warning(
    String message, {
    String? description,
    ButterToastStyle? style,
    ButterToastPosition? position,
    Duration? duration,
    Widget? icon,
    VoidCallback? onTap,
    bool dismissible = true,
    String? tag,
    bool showIcon = true,
    ButterToastTheme? theme,
  }) => show(
    message,
    description: description,
    type: ButterToastType.warning,
    style: style,
    position: position,
    duration: duration,
    icon: icon,
    onTap: onTap,
    dismissible: dismissible,
    tag: tag,
    showIcon: showIcon,
    theme: theme,
  );

  /// Shows a [ButterToastType.info] toast. See [show].
  static ButterToastHandle info(
    String message, {
    String? description,
    ButterToastStyle? style,
    ButterToastPosition? position,
    Duration? duration,
    Widget? icon,
    VoidCallback? onTap,
    bool dismissible = true,
    String? tag,
    bool showIcon = true,
    ButterToastTheme? theme,
  }) => show(
    message,
    description: description,
    type: ButterToastType.info,
    style: style,
    position: position,
    duration: duration,
    icon: icon,
    onTap: onTap,
    dismissible: dismissible,
    tag: tag,
    showIcon: showIcon,
    theme: theme,
  );

  /// Shows a [ButterToastType.loading] toast with a spinner. It stays until
  /// you call `update` or `dismiss` on the returned handle.
  static ButterToastHandle loading(
    String message, {
    String? description,
    ButterToastStyle? style,
    ButterToastPosition? position,
    bool dismissible = false,
    String? tag,
    bool showIcon = true,
    ButterToastTheme? theme,
  }) => show(
    message,
    description: description,
    type: ButterToastType.loading,
    style: style,
    position: position,
    dismissible: dismissible,
    tag: tag,
    showIcon: showIcon,
    theme: theme,
  );

  /// Shows a loading toast while [future] runs, then turns it into a
  /// success or error toast in place.
  ///
  /// Returns [future]'s result, or rethrows its error after the error toast
  /// is shown.
  ///
  /// ```dart
  /// final user = await ButterToast.promise(
  ///   api.saveProfile(),
  ///   loading: 'Saving…',
  ///   success: (_) => 'Profile saved',
  ///   error: (e) => "Couldn't save your profile",
  /// );
  /// ```
  static Future<T> promise<T>(
    Future<T> future, {
    required String loading,
    required String Function(T value) success,
    required String Function(Object error) error,
    ButterToastStyle? style,
    ButterToastPosition? position,
    String? tag,
    ButterToastTheme? theme,
  }) async {
    final toast = ButterToast.loading(
      loading,
      style: style,
      position: position,
      tag: tag,
      theme: theme,
    );
    try {
      final value = await future;
      toast.update(message: success(value), type: ButterToastType.success);
      return value;
    } catch (e) {
      toast.update(message: error(e), type: ButterToastType.error);
      rethrow;
    }
  }

  /// Shows a toast drawn entirely by [builder]. Motion, stacking, timing,
  /// swiping and the safe area still work as for the built-in styles.
  static ButterToastHandle custom({
    required ButterToastBuilder builder,
    ButterToastPosition? position,
    Duration? duration,
    VoidCallback? onTap,
    bool dismissible = true,
    String? tag,
  }) => _controller.show(
    ToastData(
      message: '',
      builder: builder,
      position: position,
      duration: duration,
      onTap: onTap,
      dismissible: dismissible,
      tag: tag,
    ),
  );

  /// Animates every toast away.
  static void dismissAll() => _controller.dismissAll();
}

/// The layer that shows toasts above [child].
///
/// Usually added through [ButterToast.init]. Place it above the `Navigator`
/// (for example in `MaterialApp.builder`) so toasts stay above dialogs and
/// bottom sheets.
class ButterToaster extends StatefulWidget {
  /// Creates the toast layer.
  const ButterToaster({super.key, required this.child, this.theme});

  /// The app.
  final Widget child;

  /// Overrides the app theme's [ButterToastTheme].
  final ButterToastTheme? theme;

  @override
  State<ButterToaster> createState() => _ButterToasterState();
}

class _ButterToasterState extends State<ButterToaster> {
  final _controller = ButterToastController();

  @override
  void initState() {
    super.initState();
    ButterToast._hosts.add(_controller);
    _controller.addListener(_changed);
  }

  @override
  void dispose() {
    ButterToast._hosts.remove(_controller);
    _controller
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    // A toast may be shown while a widget is building; wait for the frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegionSurface(
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          widget.child,
          Positioned.fill(child: _buildLayer(context)),
        ],
      ),
    );
  }

  Widget _buildLayer(BuildContext context) {
    final theme = ResolvedToastTheme.of(context, widget.theme);
    _controller
      ..defaultDuration = theme.duration
      ..defaultPosition = theme.position
      ..defaultStyle = theme.style
      ..maxToasts = theme.maxToasts;
    if (_controller.entries.isEmpty) return const SizedBox.shrink();

    final mq = MediaQuery.of(context);
    final size = mq.size;
    final keyboard = mq.viewInsets.bottom;
    final m = theme.margin;
    final top = mq.viewPadding.top + m;
    final bottom =
        (keyboard > 0 ? keyboard : mq.viewPadding.bottom + theme.bottomOffset) +
        m;
    final left = mq.viewPadding.left + m;
    final right = mq.viewPadding.right + m;

    final safeHeight = math.max(0.0, size.height - top - bottom);
    final lineHeight = mq.textScaler.scale(14) * 1.4;
    final minHeight = lineHeight + 26;
    var budget = safeHeight * theme.maxHeightFraction;
    // Too little room above the keyboard: bottom toasts move to the top.
    final moveToTop = keyboard > 0 && budget < minHeight;
    if (moveToTop) {
      budget = math.max(minHeight, (size.height - top - m) * 0.3);
    }
    final width = math.max(
      0.0,
      math.min(theme.maxWidth, size.width - left - right),
    );

    final groups = <ButterToastPosition, List<ToastEntry>>{};
    for (final entry in _controller.entries) {
      var position = _controller.positionOf(entry);
      if (moveToTop && position.isBottom) position = position.onTop;
      groups.putIfAbsent(position, () => []).add(entry);
    }

    final reduceMotion = mq.disableAnimations;
    final children = <Widget>[];
    groups.forEach((position, entries) {
      final stack = _ToastStack(
        key: ValueKey(position),
        entries: entries,
        position: position,
        theme: theme,
        controller: _controller,
        width: width,
        budget: budget,
        reduceMotion: reduceMotion,
      );
      if (position.isCenter) {
        children.add(
          Positioned(
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            child: Center(
              child: SizedBox(width: width, height: budget, child: stack),
            ),
          ),
        );
      } else {
        children.add(
          Positioned(
            top: position.isTop ? top : null,
            bottom: position.isBottom ? bottom : null,
            left: left,
            right: right,
            height: budget,
            child: Align(
              alignment: position.horizontalAlignment,
              child: SizedBox(width: width, child: stack),
            ),
          ),
        );
      }
    });

    return DefaultTextStyle(
      style: theme.textStyle,
      child: Stack(children: children),
    );
  }
}

/// The toasts at one position: a collapsed deck, or a spread-out list when
/// tapped or hovered.
class _ToastStack extends StatefulWidget {
  const _ToastStack({
    super.key,
    required this.entries,
    required this.position,
    required this.theme,
    required this.controller,
    required this.width,
    required this.budget,
    required this.reduceMotion,
  });

  final List<ToastEntry> entries;
  final ButterToastPosition position;
  final ResolvedToastTheme theme;
  final ButterToastController controller;
  final double width;
  final double budget;
  final bool reduceMotion;

  @override
  State<_ToastStack> createState() => _ToastStackState();
}

class _ToastStackState extends State<_ToastStack> {
  static const _peek = 14.0;
  static const _fallbackHeight = 52.0;

  final Map<int, double> _heights = {};
  final Map<int, _Pose> _lastPose = {};
  final Set<int> _paused = {};
  bool _tapped = false;
  bool _hovered = false;
  Timer? _hoverExit;
  Timer? _idle;

  // A stack spread out by a tap closes by itself after this long untouched.
  static const _idleCollapse = Duration(seconds: 5);

  bool get _spread => (_tapped || _hovered) && _live.length > 1;

  List<ToastEntry> get _live => [
    for (final e in widget.entries)
      if (!e.dismissing) e,
  ];

  @override
  void didUpdateWidget(_ToastStack old) {
    super.didUpdateWidget(old);
    if (_live.length <= 1) _tapped = false;
    _syncPauses();
  }

  @override
  void dispose() {
    _hoverExit?.cancel();
    _idle?.cancel();
    for (final id in _paused) {
      widget.controller.resume(id, #stack);
    }
    super.dispose();
  }

  /// Timers stop while the stack is spread out, so nothing leaves while
  /// someone is reading.
  void _syncPauses() {
    final ids = _spread ? {for (final e in _live) e.id} : <int>{};
    for (final id in ids.difference(_paused)) {
      widget.controller.pause(id, #stack);
    }
    for (final id in _paused.difference(ids)) {
      widget.controller.resume(id, #stack);
    }
    _paused
      ..clear()
      ..addAll(ids);
  }

  void _setTapped(bool value) {
    _idle?.cancel();
    if (value) {
      _idle = Timer(_idleCollapse, () {
        if (mounted) _setTapped(false);
      });
    }
    if (_tapped == value) return;
    setState(() => _tapped = value);
    _syncPauses();
  }

  void _setHovered(bool value) {
    _hoverExit?.cancel();
    if (value) {
      if (!_hovered) {
        setState(() => _hovered = true);
        _syncPauses();
      }
    } else {
      // Moving between two toasts shouldn't collapse the stack.
      _hoverExit = Timer(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        setState(() => _hovered = false);
        _syncPauses();
      });
    }
  }

  void _measured(int id, Size size) {
    if (!mounted || _heights[id] == size.height) return;
    setState(() => _heights[id] = size.height);
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final dir = position.isTop ? 1.0 : -1.0;
    final live = _live.reversed.toList(); // Newest first.
    final spread = _spread;
    final frontHeight = live.isEmpty
        ? _fallbackHeight
        : _heights[live.first.id] ?? _fallbackHeight;

    // Target pose of every live toast.
    final poses = <int, _Pose>{};
    var used = 0.0;
    for (var i = 0; i < live.length; i++) {
      final e = live[i];
      final h = _heights[e.id] ?? _fallbackHeight;
      if (position.isCenter) {
        poses[e.id] = _Pose(0, 1, i == 0 ? 1 : 0, 1);
      } else if (spread) {
        final fits = used + h <= widget.budget + 0.5;
        poses[e.id] = _Pose(dir * used, 1, fits ? 1 : 0, 1);
        used += h + widget.theme.gap;
      } else {
        poses[e.id] = _Pose(
          dir * i * _peek,
          1 - i * 0.05,
          i < widget.theme.visibleCount ? 1 : 0,
          i == 0 ? 1 : math.min(1, frontHeight / h),
        );
      }
    }
    _lastPose
      ..removeWhere((id, _) => !widget.entries.any((e) => e.id == id))
      ..addAll(poses);
    _heights.removeWhere((id, _) => !widget.entries.any((e) => e.id == id));

    final children = <Widget>[];
    for (final e in widget.entries) {
      final pose = _lastPose[e.id] ?? const _Pose(0, 1, 1, 1);
      final item = _MeasureSize(
        onChange: (size) => _measured(e.id, size),
        child: ToastItem(
          key: ValueKey(e.id),
          entry: e,
          version: e.version,
          dismissing: e.dismissing,
          position: position,
          theme: e.data.theme == null
              ? widget.theme
              : widget.theme.withToast(context, e.data.theme!),
          controller: widget.controller,
          maxHeight: widget.budget,
          reduceMotion: widget.reduceMotion,
          onTap: () => _setTapped(!_tapped),
          onHover: _setHovered,
        ),
      );
      // The pose's transform must be outermost so touches follow the toast
      // to where it has moved.
      final posed = _AnimatedPose(
        pose: pose,
        alignment: position.isTop
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        reduceMotion: widget.reduceMotion,
        child: IgnorePointer(
          ignoring: pose.opacity == 0 || e.dismissing,
          child: Align(
            alignment: position.horizontalAlignment,
            heightFactor: 1,
            child: item,
          ),
        ),
      );
      children.add(
        position.isCenter
            ? KeyedSubtree(
                key: ValueKey(e.id),
                child: Center(child: posed),
              )
            : Positioned(
                key: ValueKey(e.id),
                left: 0,
                right: 0,
                top: position.isBottom ? null : 0,
                bottom: position.isBottom ? 0 : null,
                child: posed,
              ),
      );
    }

    // Tapping anywhere else closes a spread stack. The tap still reaches
    // the app; TapRegion only watches it.
    return TapRegion(
      onTapOutside: (_) => _setTapped(false),
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }
}

/// Where one toast sits inside its stack.
@immutable
class _Pose {
  const _Pose(this.dy, this.scale, this.opacity, this.clip);

  /// Vertical offset from the stack's edge.
  final double dy;

  /// Scale; toasts further back are a little smaller.
  final double scale;

  /// 0 hides toasts beyond the visible count or the height budget.
  final double opacity;

  /// Share of the toast's height that shows; back cards are cut to the
  /// front card's height so they peek out evenly.
  final double clip;
}

/// Animates a toast to a new [_Pose] inside its stack.
class _AnimatedPose extends ImplicitlyAnimatedWidget {
  const _AnimatedPose({
    required this.pose,
    required this.alignment,
    required this.reduceMotion,
    required this.child,
  }) : super(
         duration: const Duration(milliseconds: 380),
         curve: Curves.easeOutCubic,
       );

  final _Pose pose;
  final Alignment alignment;
  final bool reduceMotion;
  final Widget child;

  @override
  AnimatedWidgetBaseState<_AnimatedPose> createState() => _AnimatedPoseState();
}

class _AnimatedPoseState extends AnimatedWidgetBaseState<_AnimatedPose> {
  Tween<double>? _dy;
  Tween<double>? _scale;
  Tween<double>? _opacity;
  Tween<double>? _clip;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    Tween<double> make(dynamic v) => Tween<double>(begin: v as double);
    _dy = visitor(_dy, widget.pose.dy, make) as Tween<double>?;
    _scale = visitor(_scale, widget.pose.scale, make) as Tween<double>?;
    _opacity = visitor(_opacity, widget.pose.opacity, make) as Tween<double>?;
    _clip = visitor(_clip, widget.pose.clip, make) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final dy = _dy?.evaluate(animation) ?? 0;
    final scale = widget.reduceMotion
        ? 1.0
        : _scale?.evaluate(animation) ?? 1.0;
    final opacity = (_opacity?.evaluate(animation) ?? 1).clamp(0.0, 1.0);
    final clip = (_clip?.evaluate(animation) ?? 1).clamp(0.0, 1.0);

    Widget child = widget.child;
    if (clip < 0.999) {
      // Show the edge that peeks out from behind the front toast.
      child = ClipRect(
        child: Align(
          alignment: widget.alignment == Alignment.topCenter
              ? Alignment.bottomCenter
              : Alignment.topCenter,
          heightFactor: clip,
          child: child,
        ),
      );
    }
    return Transform.translate(
      offset: Offset(0, dy),
      child: Transform.scale(
        scale: scale,
        alignment: widget.alignment,
        child: Opacity(opacity: opacity, child: child),
      ),
    );
  }
}

/// Reports its child's size after layout.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final current = size;
    if (current == _reported) return;
    _reported = current;
    SchedulerBinding.instance.addPostFrameCallback((_) => onChange(current));
  }
}
