import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'theme.dart';
import 'types.dart';
import 'view.dart';

/// One toast with its motion: spring in, animate out, swipe away.
class ToastItem extends StatefulWidget {
  /// Creates the animated toast for [entry].
  const ToastItem({
    super.key,
    required this.entry,
    required this.version,
    required this.dismissing,
    required this.position,
    required this.theme,
    required this.controller,
    required this.maxHeight,
    required this.reduceMotion,
    required this.onTap,
    required this.onHover,
  });

  /// The toast to show.
  final ToastEntry entry;

  /// [ToastEntry.version] at build time, so updates rebuild the view.
  final int version;

  /// Whether the toast should animate out.
  final bool dismissing;

  /// Where the toast is, which picks the direction of every motion.
  final ButterToastPosition position;

  /// Colours and sizes.
  final ResolvedToastTheme theme;

  /// Owner of the toast.
  final ButterToastController controller;

  /// Tallest the toast may be.
  final double maxHeight;

  /// Whether to fade only, for users who asked for less motion.
  final bool reduceMotion;

  /// Called on tap.
  final VoidCallback onTap;

  /// Called when a mouse enters (true) or leaves (false) the toast.
  final ValueChanged<bool> onHover;

  @override
  State<ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<ToastItem> with TickerProviderStateMixin {
  // A little bounce: damping ratio about 0.67.
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 26,
  );

  // Unbounded so the spring can overshoot 1 slightly.
  late final AnimationController _presence = AnimationController.unbounded(
    vsync: this,
  );
  // Where the finger has dragged the toast, on both axes.
  late final AnimationController _dx = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _dy = AnimationController.unbounded(
    vsync: this,
  );

  bool _exiting = false;
  bool _textExpanded = false;

  ButterToastPosition get _position => widget.position;

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) {
      _presence.animateTo(1, duration: const Duration(milliseconds: 180));
    } else {
      _presence.animateWith(SpringSimulation(_spring, 0, 1, 0));
    }
    if (widget.dismissing) _exit();
  }

  @override
  void didUpdateWidget(ToastItem old) {
    super.didUpdateWidget(old);
    if (widget.dismissing && !_exiting) _exit();
  }

  @override
  void dispose() {
    _presence.dispose();
    _dx.dispose();
    _dy.dispose();
    super.dispose();
  }

  void _exit() {
    _exiting = true;
    _presence.stop();
    _presence
        .animateTo(
          0,
          duration: Duration(milliseconds: widget.reduceMotion ? 150 : 220),
          curve: Curves.easeInCubic,
        )
        .whenComplete(() => widget.controller.remove(widget.entry.id));
  }

  void _toggleText() {
    setState(() => _textExpanded = !_textExpanded);
    if (_textExpanded) {
      widget.controller.pause(widget.entry.id, #text);
    } else {
      widget.controller.resume(widget.entry.id, #text);
    }
  }

  void _dragStart(DragStartDetails _) {
    if (_exiting) return;
    _dx.stop();
    _dy.stop();
    widget.controller.pause(widget.entry.id, #drag);
  }

  // A toast follows the finger in any direction.
  void _dragUpdate(DragUpdateDetails details) {
    if (_exiting) return;
    _dx.value += details.delta.dx;
    _dy.value += details.delta.dy;
  }

  void _dragEnd(DragEndDetails details) {
    if (_exiting) return;
    widget.controller.resume(widget.entry.id, #drag);
    final velocity = details.velocity.pixelsPerSecond;
    final size = context.size ?? Size.zero;
    final offset = Offset(_dx.value, _dy.value);

    // Dragged far enough in any direction, or thrown fast enough.
    final farEnough =
        _dx.value.abs() > size.width * 0.35 ||
        _dy.value.abs() > math.max(40, size.height * 0.8);
    final fastEnough = velocity.distance > 800;

    if (farEnough || fastEnough) {
      _exiting = true;
      // Fly out the way it was thrown, or the way it was dragged.
      final direction = fastEnough
          ? velocity / velocity.distance
          : offset / math.max(offset.distance, 1);
      final screen = MediaQuery.sizeOf(context);
      final target = offset + direction * (screen.longestSide * 0.6);
      const out = Duration(milliseconds: 200);
      _dx.animateTo(target.dx, duration: out, curve: Curves.easeOut);
      _dy
          .animateTo(target.dy, duration: out, curve: Curves.easeOut)
          .whenComplete(() => widget.controller.remove(widget.entry.id));
    } else {
      _dx.animateWith(SpringSimulation(_spring, _dx.value, 0, velocity.dx));
      _dy.animateWith(SpringSimulation(_spring, _dy.value, 0, velocity.dy));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.entry.data;
    final style = data.style ?? widget.theme.style;
    final builder = data.builder;

    Widget view = builder != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: builder(
              context,
              widget.controller.handleOf(widget.entry.id),
            ),
          )
        : ToastView(
            data: data,
            style: style,
            theme: widget.theme,
            maxHeight: widget.maxHeight,
            textExpanded: _textExpanded,
            onToggleText: _toggleText,
          );

    // An update (such as loading -> success) morphs in place.
    view = AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: _position.isTop ? Alignment.topCenter : Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          children: [...previous, ?current],
        ),
        child: KeyedSubtree(key: ValueKey(widget.version), child: view),
      ),
    );

    view = Semantics(liveRegion: true, container: true, child: view);

    final swipe = data.dismissible && !_exiting;
    view = MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: () {
          data.onTap?.call();
          widget.onTap();
        },
        onPanStart: swipe ? _dragStart : null,
        onPanUpdate: swipe ? _dragUpdate : null,
        onPanEnd: swipe ? _dragEnd : null,
        dragStartBehavior: DragStartBehavior.down,
        child: view,
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_presence, _dx, _dy]),
      child: view,
      builder: (context, child) {
        final p = _presence.value;
        final visible = p.clamp(0.0, 1.0);
        final drag = Offset(_dx.value, _dy.value);
        final dragFade = (1 - drag.distance / 320).clamp(0.0, 1.0);

        Widget result = child!;
        if (!widget.reduceMotion) {
          if (_position.isCenter) {
            result = Transform.scale(scale: 0.85 + 0.15 * p, child: result);
          } else if (_position.side != 0) {
            result = FractionalTranslation(
              translation: Offset((1 - p) * 1.15 * _position.side, 0),
              child: result,
            );
          } else {
            result = FractionalTranslation(
              translation: Offset(
                0,
                (1 - p) * 1.3 * (_position.isTop ? -1 : 1),
              ),
              child: result,
            );
          }
        }
        // The drag offset is outermost so touches follow a dragged toast.
        return Transform.translate(
          offset: drag,
          child: Opacity(opacity: visible * dragFade, child: result),
        );
      },
    );
  }
}
