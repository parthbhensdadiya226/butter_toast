import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'types.dart';

/// App-wide look and behaviour of toasts.
///
/// Add it to `ThemeData.extensions` (one for `theme`, one for `darkTheme`),
/// or pass it to `ButterToast.init(theme: ...)`. Every field is optional;
/// anything left null comes from the app's [ColorScheme] and text theme.
@immutable
class ButterToastTheme extends ThemeExtension<ButterToastTheme> {
  /// Creates a toast theme. Null fields use the defaults.
  const ButterToastTheme({
    this.style,
    this.position,
    this.duration,
    this.maxHeightFraction,
    this.maxLines,
    this.maxWidth,
    this.bottomOffset,
    this.margin,
    this.gap,
    this.visibleCount,
    this.maxToasts,
    this.cardColor,
    this.cardForegroundColor,
    this.cardBorderColor,
    this.cardBorderRadius,
    this.pillColor,
    this.pillForegroundColor,
    this.successColor,
    this.errorColor,
    this.warningColor,
    this.infoColor,
    this.textStyle,
    this.shadows,
    this.icon,
    this.typeIcons,
  });

  /// Default look: [ButterToastStyle.pill] unless set.
  final ButterToastStyle? style;

  /// Default position: [ButterToastPosition.bottomCenter] unless set.
  final ButterToastPosition? position;

  /// How long a toast stays. 4 seconds unless set.
  final Duration? duration;

  /// Most of the safe screen height that toasts at one position may use,
  /// from 0 to 1. 0.4 unless set. Longer text collapses behind "Show more".
  final double? maxHeightFraction;

  /// Most lines of text shown before "Show more". 3 unless set. Fewer are
  /// shown when space is tight, such as above the keyboard.
  final int? maxLines;

  /// Widest a toast gets, in logical pixels. 420 unless set.
  final double? maxWidth;

  /// Extra space kept free at the bottom, for example above a bottom
  /// navigation bar. Ignored while the keyboard is open. 0 unless set.
  final double? bottomOffset;

  /// Distance from the safe area edges. 16 unless set.
  final double? margin;

  /// Space between toasts when a stack is spread out. 8 unless set.
  final double? gap;

  /// How many stacked cards peek out behind the front one. 3 unless set.
  final int? visibleCount;

  /// Most toasts kept at one position; older ones leave first. 5 unless
  /// set.
  final int? maxToasts;

  /// Background of [ButterToastStyle.card] toasts.
  final Color? cardColor;

  /// Text and default icon colour of card toasts.
  final Color? cardForegroundColor;

  /// Border of card toasts.
  final Color? cardBorderColor;

  /// Corner radius of card toasts. 14 unless set.
  final double? cardBorderRadius;

  /// Background of [ButterToastStyle.pill] toasts.
  final Color? pillColor;

  /// Text colour of pill toasts.
  final Color? pillForegroundColor;

  /// Icon colour for [ButterToastType.success].
  final Color? successColor;

  /// Icon colour for [ButterToastType.error].
  final Color? errorColor;

  /// Icon colour for [ButterToastType.warning].
  final Color? warningColor;

  /// Icon colour for [ButterToastType.info].
  final Color? infoColor;

  /// Base text style, merged over the app's `bodyMedium`.
  final TextStyle? textStyle;

  /// Shadows under toasts.
  final List<BoxShadow>? shadows;

  /// Icon for toasts of [ButterToastType.normal], such as your app logo.
  /// Use `const ButterToastAppIcon()` for the app's launcher icon.
  final Widget? icon;

  /// Whether success, error, warning and info toasts show their own icons.
  /// Set to false to show [icon] on every toast instead. True unless set.
  final bool? typeIcons;

  /// Fields of this theme, with the null ones taken from [other].
  ButterToastTheme merge(ButterToastTheme? other) {
    if (other == null) return this;
    return ButterToastTheme(
      style: style ?? other.style,
      position: position ?? other.position,
      duration: duration ?? other.duration,
      maxHeightFraction: maxHeightFraction ?? other.maxHeightFraction,
      maxLines: maxLines ?? other.maxLines,
      maxWidth: maxWidth ?? other.maxWidth,
      bottomOffset: bottomOffset ?? other.bottomOffset,
      margin: margin ?? other.margin,
      gap: gap ?? other.gap,
      visibleCount: visibleCount ?? other.visibleCount,
      maxToasts: maxToasts ?? other.maxToasts,
      cardColor: cardColor ?? other.cardColor,
      cardForegroundColor: cardForegroundColor ?? other.cardForegroundColor,
      cardBorderColor: cardBorderColor ?? other.cardBorderColor,
      cardBorderRadius: cardBorderRadius ?? other.cardBorderRadius,
      pillColor: pillColor ?? other.pillColor,
      pillForegroundColor: pillForegroundColor ?? other.pillForegroundColor,
      successColor: successColor ?? other.successColor,
      errorColor: errorColor ?? other.errorColor,
      warningColor: warningColor ?? other.warningColor,
      infoColor: infoColor ?? other.infoColor,
      textStyle: textStyle ?? other.textStyle,
      shadows: shadows ?? other.shadows,
      icon: icon ?? other.icon,
      typeIcons: typeIcons ?? other.typeIcons,
    );
  }

  @override
  ButterToastTheme copyWith({
    ButterToastStyle? style,
    ButterToastPosition? position,
    Duration? duration,
    double? maxHeightFraction,
    int? maxLines,
    double? maxWidth,
    double? bottomOffset,
    double? margin,
    double? gap,
    int? visibleCount,
    int? maxToasts,
    Color? cardColor,
    Color? cardForegroundColor,
    Color? cardBorderColor,
    double? cardBorderRadius,
    Color? pillColor,
    Color? pillForegroundColor,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? infoColor,
    TextStyle? textStyle,
    List<BoxShadow>? shadows,
    Widget? icon,
    bool? typeIcons,
  }) => ButterToastTheme(
    style: style ?? this.style,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    maxHeightFraction: maxHeightFraction ?? this.maxHeightFraction,
    maxLines: maxLines ?? this.maxLines,
    maxWidth: maxWidth ?? this.maxWidth,
    bottomOffset: bottomOffset ?? this.bottomOffset,
    margin: margin ?? this.margin,
    gap: gap ?? this.gap,
    visibleCount: visibleCount ?? this.visibleCount,
    maxToasts: maxToasts ?? this.maxToasts,
    cardColor: cardColor ?? this.cardColor,
    cardForegroundColor: cardForegroundColor ?? this.cardForegroundColor,
    cardBorderColor: cardBorderColor ?? this.cardBorderColor,
    cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
    pillColor: pillColor ?? this.pillColor,
    pillForegroundColor: pillForegroundColor ?? this.pillForegroundColor,
    successColor: successColor ?? this.successColor,
    errorColor: errorColor ?? this.errorColor,
    warningColor: warningColor ?? this.warningColor,
    infoColor: infoColor ?? this.infoColor,
    textStyle: textStyle ?? this.textStyle,
    shadows: shadows ?? this.shadows,
    icon: icon ?? this.icon,
    typeIcons: typeIcons ?? this.typeIcons,
  );

  @override
  ButterToastTheme lerp(ButterToastTheme? other, double t) {
    if (other == null) return this;
    T pick<T>(T a, T b) => t < 0.5 ? a : b;
    return ButterToastTheme(
      style: pick(style, other.style),
      position: pick(position, other.position),
      duration: pick(duration, other.duration),
      maxHeightFraction: lerpDouble(
        maxHeightFraction,
        other.maxHeightFraction,
        t,
      ),
      maxLines: pick(maxLines, other.maxLines),
      maxWidth: lerpDouble(maxWidth, other.maxWidth, t),
      bottomOffset: lerpDouble(bottomOffset, other.bottomOffset, t),
      margin: lerpDouble(margin, other.margin, t),
      gap: lerpDouble(gap, other.gap, t),
      visibleCount: pick(visibleCount, other.visibleCount),
      maxToasts: pick(maxToasts, other.maxToasts),
      cardColor: Color.lerp(cardColor, other.cardColor, t),
      cardForegroundColor: Color.lerp(
        cardForegroundColor,
        other.cardForegroundColor,
        t,
      ),
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t),
      cardBorderRadius: lerpDouble(cardBorderRadius, other.cardBorderRadius, t),
      pillColor: Color.lerp(pillColor, other.pillColor, t),
      pillForegroundColor: Color.lerp(
        pillForegroundColor,
        other.pillForegroundColor,
        t,
      ),
      successColor: Color.lerp(successColor, other.successColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      shadows: BoxShadow.lerpList(shadows, other.shadows, t),
      icon: pick(icon, other.icon),
      typeIcons: pick(typeIcons, other.typeIcons),
    );
  }
}

/// A [ButterToastTheme] with every value filled in.
@immutable
class ResolvedToastTheme {
  const ResolvedToastTheme._({
    required this.style,
    required this.position,
    required this.duration,
    required this.maxHeightFraction,
    required this.maxLines,
    required this.maxWidth,
    required this.bottomOffset,
    required this.margin,
    required this.gap,
    required this.visibleCount,
    required this.maxToasts,
    required this.cardColor,
    required this.cardForegroundColor,
    required this.cardBorderColor,
    required this.cardBorderRadius,
    required this.pillColor,
    required this.pillForegroundColor,
    required this.textStyle,
    required this.shadows,
    required ButterToastTheme source,
  }) : _source = source;

  /// Resolves the theme for [context]: [override] first, then the app
  /// theme's [ButterToastTheme] extension, then the defaults.
  factory ResolvedToastTheme.of(
    BuildContext context, [
    ButterToastTheme? override,
  ]) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final t = (override ?? const ButterToastTheme()).merge(
      theme.extension<ButterToastTheme>(),
    );
    final base = (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14))
        .copyWith(height: 1.4, fontSize: 14);
    return ResolvedToastTheme._(
      style: t.style ?? ButterToastStyle.pill,
      position: t.position ?? ButterToastPosition.bottomCenter,
      duration: t.duration ?? const Duration(seconds: 4),
      maxHeightFraction: (t.maxHeightFraction ?? 0.4).clamp(0.1, 1.0),
      maxLines: math.max(1, t.maxLines ?? 3),
      maxWidth: t.maxWidth ?? 420,
      bottomOffset: t.bottomOffset ?? 0,
      margin: t.margin ?? 16,
      gap: t.gap ?? 8,
      visibleCount: math.max(1, t.visibleCount ?? 3),
      maxToasts: math.max(1, t.maxToasts ?? 5),
      cardColor:
          t.cardColor ??
          (dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest),
      cardForegroundColor: t.cardForegroundColor ?? scheme.onSurface,
      cardBorderColor: t.cardBorderColor ?? scheme.outlineVariant,
      cardBorderRadius: t.cardBorderRadius ?? 14,
      pillColor:
          t.pillColor ??
          (dark ? const Color(0xFFE8E8EA) : const Color(0xFF2B2B2E)),
      pillForegroundColor:
          t.pillForegroundColor ??
          (dark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F7)),
      textStyle: base.merge(t.textStyle),
      shadows:
          t.shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.2 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
      source: t,
    );
  }

  /// Default look.
  final ButterToastStyle style;

  /// Default position.
  final ButterToastPosition position;

  /// Default duration.
  final Duration duration;

  /// Share of the safe height toasts may use.
  final double maxHeightFraction;

  /// Most lines before "Show more".
  final int maxLines;

  /// Widest a toast gets.
  final double maxWidth;

  /// Space kept free above the bottom safe area.
  final double bottomOffset;

  /// Distance from the safe area edges.
  final double margin;

  /// Space between spread-out toasts.
  final double gap;

  /// Cards peeking out of a collapsed stack.
  final int visibleCount;

  /// Most toasts at one position.
  final int maxToasts;

  /// Card background.
  final Color cardColor;

  /// Card text colour.
  final Color cardForegroundColor;

  /// Card border colour.
  final Color cardBorderColor;

  /// Card corner radius.
  final double cardBorderRadius;

  /// Pill background.
  final Color pillColor;

  /// Pill text colour.
  final Color pillForegroundColor;

  /// Base text style.
  final TextStyle textStyle;

  /// Shadows under toasts.
  final List<BoxShadow> shadows;

  final ButterToastTheme _source;

  /// Icon for plain toasts, and for every toast when [typeIcons] is false.
  Widget? get icon => _source.icon;

  /// Whether typed toasts keep their own icons.
  bool get typeIcons => _source.typeIcons ?? true;

  /// Background for [style].
  Color background(ButterToastStyle style) =>
      style == ButterToastStyle.pill ? pillColor : cardColor;

  /// Text colour for [style].
  Color foreground(ButterToastStyle style) => style == ButterToastStyle.pill
      ? pillForegroundColor
      : cardForegroundColor;

  /// Icon colour for [type] on a toast of [style].
  Color iconColor(ButterToastType type, ButterToastStyle style) {
    final onDark =
        ThemeData.estimateBrightnessForColor(background(style)) ==
        Brightness.dark;
    return switch (type) {
      ButterToastType.success =>
        _source.successColor ??
            (onDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
      ButterToastType.error =>
        _source.errorColor ??
            (onDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
      ButterToastType.warning =>
        _source.warningColor ??
            (onDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
      ButterToastType.info =>
        _source.infoColor ??
            (onDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
      ButterToastType.normal || ButterToastType.loading => foreground(style),
    };
  }
}
