import 'dart:async';

import 'package:flutter/foundation.dart';

import 'types.dart';

/// A toast that has been shown. Use it to change or dismiss that toast.
@immutable
class ButterToastHandle {
  const ButterToastHandle._(this.id, this._controller);

  /// Unique id of the toast.
  final int id;

  final ButterToastController _controller;

  /// Whether the toast is still on screen and not leaving.
  bool get isActive => _controller.isActive(id);

  /// Animates the toast away.
  void dismiss() => _controller.dismiss(id);

  /// Changes the toast in place. The toast morphs to its new content and its
  /// timer starts again. Turning a [ButterToastType.loading] toast into any
  /// other type starts its timer.
  void update({
    String? message,
    String? description,
    ButterToastType? type,
    Duration? duration,
  }) => _controller.update(
    id,
    message: message,
    description: description,
    type: type,
    duration: duration,
  );

  @override
  bool operator ==(Object other) =>
      other is ButterToastHandle &&
      other.id == id &&
      identical(other._controller, _controller);

  @override
  int get hashCode => Object.hash(id, _controller);
}

/// One toast managed by a [ButterToastController].
class ToastEntry {
  ToastEntry._(this.id, this.data);

  /// Unique id of the toast.
  final int id;

  /// What the toast shows. Replaced by [ButterToastController.update].
  ToastData data;

  /// Bumped on every update, so the view can animate the change.
  int version = 0;

  /// Whether the toast is animating away.
  bool dismissing = false;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  final Stopwatch _running = Stopwatch();
  final Set<Object> _pauses = <Object>{};
}

/// Keeps the list of toasts and their timers. The toast layer listens to it.
class ButterToastController extends ChangeNotifier {
  /// Duration used when a toast doesn't set one.
  Duration defaultDuration = const Duration(seconds: 4);

  /// Position used when a toast doesn't set one.
  ButterToastPosition defaultPosition = ButterToastPosition.bottomCenter;

  /// Style used when a toast doesn't set one.
  ButterToastStyle defaultStyle = ButterToastStyle.pill;

  /// Most toasts kept at one position. Older ones leave first.
  int maxToasts = 5;

  /// Whether a toast identical to one on screen restarts that toast instead
  /// of adding a copy.
  bool mergeDuplicates = true;

  final List<ToastEntry> _entries = <ToastEntry>[];
  int _nextId = 1;
  bool _disposed = false;

  /// All toasts, oldest first, including the ones animating away.
  List<ToastEntry> get entries => _entries;

  /// Where [entry] is shown.
  ButterToastPosition positionOf(ToastEntry entry) =>
      entry.data.position ?? defaultPosition;

  /// Whether the toast with [id] is on screen and not leaving.
  bool isActive(int id) => _find(id)?.dismissing == false;

  /// The handle for the toast with [id].
  ButterToastHandle handleOf(int id) => ButterToastHandle._(id, this);

  /// Shows a toast and returns its handle.
  ///
  /// A toast with the same [ToastData.tag] as one on screen replaces that
  /// toast in place. A toast identical to one already on screen at the same
  /// position isn't added again; the existing one restarts its timer
  /// instead. Both stop repeated taps from piling up toasts.
  ///
  /// Toasts with an action or `onDismiss` are never merged, since each one
  /// has its own callbacks. Neither are any when [mergeDuplicates] (or the
  /// toast's own theme) turns merging off.
  ButterToastHandle show(ToastData data) {
    final position = data.position ?? defaultPosition;
    // A toast keeps the position and style it was shown with, even if the
    // defaults change while it's on screen.
    data = data.resolved(position, data.style ?? defaultStyle);

    final tag = data.tag;
    final merge = data.theme?.mergeDuplicates ?? mergeDuplicates;
    for (final entry in _entries) {
      if (entry.dismissing) continue;
      if (tag != null && entry.data.tag == tag) {
        _notifyDismiss(entry.data, ButterToastDismissReason.replaced);
        entry
          ..data = data.resolved(positionOf(entry), data.style!)
          ..version += 1;
        _restartTimer(entry);
        notifyListeners();
        return handleOf(entry.id);
      }
      if (tag == null &&
          merge &&
          positionOf(entry) == position &&
          entry.data.sameContentAs(data)) {
        _restartTimer(entry);
        return handleOf(entry.id);
      }
    }

    final entry = ToastEntry._(_nextId++, data);
    _entries.add(entry);

    final live = [
      for (final e in _entries)
        if (!e.dismissing && positionOf(e) == position) e,
    ];
    final limit = position.isCenter ? 1 : maxToasts;
    for (var i = 0; i < live.length - limit; i++) {
      _markDismissing(live[i], ButterToastDismissReason.limit);
    }

    _restartTimer(entry);
    notifyListeners();
    return handleOf(entry.id);
  }

  /// Changes the toast with [id]; see [ButterToastHandle.update].
  void update(
    int id, {
    String? message,
    String? description,
    ButterToastType? type,
    Duration? duration,
  }) {
    final entry = _find(id);
    if (entry == null || entry.dismissing) return;
    entry
      ..data = entry.data.copyWith(
        message: message,
        description: description,
        type: type,
        duration: duration,
      )
      ..version += 1;
    _restartTimer(entry);
    notifyListeners();
  }

  /// Animates the toast with [id] away. [reason] is passed to its
  /// `onDismiss`.
  void dismiss(
    int id, [
    ButterToastDismissReason reason = ButterToastDismissReason.programmatic,
  ]) {
    final entry = _find(id);
    if (entry == null || entry.dismissing) return;
    _markDismissing(entry, reason);
    notifyListeners();
  }

  /// Animates away every toast with [tag].
  void dismissTag(String tag) =>
      _dismissWhere((entry) => entry.data.tag == tag);

  /// Animates every toast away.
  void dismissAll() => _dismissWhere((_) => true);

  void _dismissWhere(bool Function(ToastEntry entry) test) {
    var changed = false;
    for (final entry in _entries) {
      if (!entry.dismissing && test(entry)) {
        _markDismissing(entry, ButterToastDismissReason.programmatic);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Removes the toast with [id] at once. Called when its exit animation
  /// ends.
  void remove(int id) {
    final entry = _find(id);
    if (entry == null) return;
    entry._timer?.cancel();
    _entries.remove(entry);
    if (!_disposed) notifyListeners();
  }

  /// Stops the timer of the toast with [id] until every [reason] given here
  /// has been passed to [resume].
  void pause(int id, Object reason) {
    final entry = _find(id);
    if (entry == null || !entry._pauses.add(reason)) return;
    if (entry._pauses.length == 1 && entry._timer != null) {
      entry._timer!.cancel();
      entry._timer = null;
      entry._running.stop();
      final left = entry._remaining - entry._running.elapsed;
      // Leave a moment to read it once the pause ends.
      const floor = Duration(milliseconds: 1500);
      entry._remaining = left < floor ? floor : left;
    }
  }

  /// Ends a pause started with [pause].
  void resume(int id, Object reason) {
    final entry = _find(id);
    if (entry == null || !entry._pauses.remove(reason)) return;
    if (entry._pauses.isEmpty) _startTimer(entry);
  }

  ToastEntry? _find(int id) {
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  void _markDismissing(ToastEntry entry, ButterToastDismissReason reason) {
    entry
      ..dismissing = true
      .._timer?.cancel()
      .._timer = null;
    _notifyDismiss(entry.data, reason);
  }

  // Called after the current change, so a callback that shows another toast
  // doesn't change the list while it's being walked.
  void _notifyDismiss(ToastData data, ButterToastDismissReason reason) {
    final onDismiss = data.onDismiss;
    if (onDismiss != null) scheduleMicrotask(() => onDismiss(reason));
  }

  void _restartTimer(ToastEntry entry) {
    entry._timer?.cancel();
    entry._timer = null;
    entry._remaining = entry.data.duration ?? defaultDuration;
    _startTimer(entry);
  }

  void _startTimer(ToastEntry entry) {
    if (entry.dismissing ||
        entry._pauses.isNotEmpty ||
        entry.data.type == ButterToastType.loading ||
        entry._remaining <= Duration.zero) {
      return;
    }
    entry._running
      ..reset()
      ..start();
    entry._timer = Timer(
      entry._remaining,
      () => dismiss(entry.id, ButterToastDismissReason.timeout),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    for (final entry in _entries) {
      entry._timer?.cancel();
    }
    super.dispose();
  }
}
