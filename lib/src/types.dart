import 'package:flutter/widgets.dart';

import 'controller.dart' show ButterToastHandle;
import 'theme.dart' show ButterToastTheme;

/// What a toast is about. It picks the default icon and its colour.
enum ButterToastType {
  /// A plain message without an icon.
  normal,

  /// Something worked.
  success,

  /// Something failed.
  error,

  /// Something needs attention.
  warning,

  /// Neutral information.
  info,

  /// Work in progress, shown with a spinner. It stays until it is updated or
  /// dismissed.
  loading,
}

/// How a toast looks.
enum ButterToastStyle {
  /// A compact pill that hugs its text, like the platform toast.
  pill,

  /// A card with a title and an optional description. Several cards stack
  /// like a deck and spread out when tapped or hovered.
  card,
}

/// Where toasts appear on screen.
///
/// The position also decides the motion: top and bottom toasts slide in from
/// their edge, corner toasts slide in from the side, and centre toasts scale
/// in.
enum ButterToastPosition {
  /// Top left corner. Slides in from the left.
  topLeft,

  /// Top edge, centred. Slides down from the top.
  topCenter,

  /// Top right corner. Slides in from the right.
  topRight,

  /// Middle of the screen. Scales in and replaces the previous toast.
  center,

  /// Bottom left corner. Slides in from the left.
  bottomLeft,

  /// Bottom edge, centred. Slides up from the bottom.
  bottomCenter,

  /// Bottom right corner. Slides in from the right.
  bottomRight;

  /// Whether the toast sits along the top edge.
  bool get isTop => this == topLeft || this == topCenter || this == topRight;

  /// Whether the toast sits along the bottom edge.
  bool get isBottom =>
      this == bottomLeft || this == bottomCenter || this == bottomRight;

  /// Whether the toast sits in the middle of the screen.
  bool get isCenter => this == center;

  /// -1 for the left corners, 1 for the right corners, 0 otherwise.
  int get side => switch (this) {
    topLeft || bottomLeft => -1,
    topRight || bottomRight => 1,
    _ => 0,
  };

  /// The same horizontal placement along the top edge.
  ButterToastPosition get onTop => switch (this) {
    bottomLeft => topLeft,
    bottomCenter => topCenter,
    bottomRight => topRight,
    _ => this,
  };

  /// Horizontal alignment of the toast inside its row.
  Alignment get horizontalAlignment => switch (side) {
    -1 => Alignment.centerLeft,
    1 => Alignment.centerRight,
    _ => Alignment.center,
  };
}

/// Builds a fully custom toast. The package still handles the motion,
/// stacking, timing, swiping and the safe area around it.
typedef ButterToastBuilder =
    Widget Function(BuildContext context, ButterToastHandle toast);

/// Everything needed to show one toast.
@immutable
class ToastData {
  /// Creates the data for one toast.
  const ToastData({
    required this.message,
    this.description,
    this.type = ButterToastType.normal,
    this.style,
    this.position,
    this.duration,
    this.icon,
    this.onTap,
    this.dismissible = true,
    this.builder,
    this.tag,
    this.showIcon = true,
    this.theme,
  });

  /// The main text. In a card this is the title.
  final String message;

  /// Optional second line of text.
  final String? description;

  /// What the toast is about.
  final ButterToastType type;

  /// Look of this toast, or null for the theme's style.
  final ButterToastStyle? style;

  /// Position of this toast, or null for the theme's position.
  final ButterToastPosition? position;

  /// How long it stays, or null for the theme's duration. [Duration.zero]
  /// keeps it until it is dismissed.
  final Duration? duration;

  /// Replaces the icon for this toast.
  final Widget? icon;

  /// Called when the toast is tapped.
  final VoidCallback? onTap;

  /// Whether the toast can be swiped away.
  final bool dismissible;

  /// Draws the whole toast instead of the built-in styles.
  final ButterToastBuilder? builder;

  /// Identifies the toast: showing another toast with the same tag replaces
  /// this one in place instead of adding a new one.
  final String? tag;

  /// Whether to show an icon at all.
  final bool showIcon;

  /// Theme for this toast only, laid over the app's toast theme.
  final ButterToastTheme? theme;

  /// Whether [other] would show the same thing, so it can be merged.
  bool sameContentAs(ToastData other) =>
      builder == null &&
      other.builder == null &&
      message == other.message &&
      description == other.description &&
      type == other.type &&
      style == other.style &&
      theme == other.theme;

  /// A copy shown at [position] with [style].
  ToastData resolved(ButterToastPosition position, ButterToastStyle style) =>
      _copy(position: position, style: style);

  /// A copy with the given fields replaced.
  ToastData copyWith({
    String? message,
    String? description,
    ButterToastType? type,
    Duration? duration,
  }) => _copy(
    message: message,
    description: description,
    type: type,
    duration: duration,
  );

  ToastData _copy({
    String? message,
    String? description,
    ButterToastType? type,
    Duration? duration,
    ButterToastPosition? position,
    ButterToastStyle? style,
  }) => ToastData(
    message: message ?? this.message,
    description: description ?? this.description,
    type: type ?? this.type,
    style: style ?? this.style,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    icon: icon,
    onTap: onTap,
    dismissible: dismissible,
    builder: builder,
    tag: tag,
    showIcon: showIcon,
    theme: theme,
  );
}
