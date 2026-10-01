import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'types.dart';

/// The built-in pill and card look of a toast.
class ToastView extends StatelessWidget {
  /// Creates the view for [data].
  const ToastView({
    super.key,
    required this.data,
    required this.style,
    required this.theme,
    required this.maxHeight,
    required this.textExpanded,
    required this.onToggleText,
    this.onAction,
    this.onClose,
  });

  /// What to show.
  final ToastData data;

  /// Pill or card.
  final ButterToastStyle style;

  /// Colours and sizes.
  final ResolvedToastTheme theme;

  /// Tallest the whole toast may be.
  final double maxHeight;

  /// Whether the full text is shown ("Show more" was tapped).
  final bool textExpanded;

  /// Switches between the short and the full text.
  final VoidCallback onToggleText;

  /// Called when the action button is pressed. The button shows when
  /// [ToastData.action] is set.
  final VoidCallback? onAction;

  /// Called when the close button is pressed, or null for no close button.
  final VoidCallback? onClose;

  bool get _pill => style == ButterToastStyle.pill;

  EdgeInsets get _padding => _pill
      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 11)
      : const EdgeInsets.fromLTRB(14, 12, 16, 12);

  @override
  Widget build(BuildContext context) {
    final foreground = theme.foreground(style);
    final icon = _icon(foreground);
    final radius = BorderRadius.circular(_pill ? 22 : theme.cardBorderRadius);
    final action = data.action;
    final hasTrailing = action != null || onClose != null;

    return Container(
      // Cards share one width so a stack lines up; pills hug their text.
      width: _pill ? null : double.infinity,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.background(style),
        borderRadius: radius,
        border: _pill
            ? null
            : Border.all(color: theme.cardBorderColor, width: 0.8),
        boxShadow: theme.shadows,
      ),
      padding: _padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // Buttons are taller than a line of text; centre the row on them.
        crossAxisAlignment: hasTrailing
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(padding: const EdgeInsets.only(top: 1), child: icon),
            const SizedBox(width: 10),
          ],
          Flexible(
            // A card is full width, so its text fills the row and pushes the
            // buttons to the far edge. A pill hugs its text.
            fit: _pill ? FlexFit.loose : FlexFit.tight,
            // The toast's live region reads the text out as one label.
            child: ExcludeSemantics(
              child: _ToastText(
                data: data,
                pill: _pill,
                style: theme.textStyle.copyWith(color: foreground),
                maxLines: theme.maxLines,
                // The text may use whatever the padding leaves.
                maxHeight: math.max(0, maxHeight - _padding.vertical),
                expanded: textExpanded,
                onToggle: onToggleText,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            _ActionButton(
              label: action.label,
              pill: _pill,
              background: foreground,
              foreground: theme.background(style),
              onPressed: onAction,
            ),
          ],
          if (onClose != null) ...[
            SizedBox(width: action != null ? 4 : 8),
            _CloseButton(color: foreground, onPressed: onClose!),
          ],
        ],
      ),
    );
  }

  Widget? _icon(Color foreground) {
    const size = 18.0;
    if (!data.showIcon) return null;
    final color = theme.iconColor(data.type, style);
    Widget sized(Widget icon) => IconTheme.merge(
      data: IconThemeData(size: size, color: color),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: icon),
      ),
    );

    if (data.icon != null) return sized(data.icon!);
    if (data.type == ButterToastType.loading) {
      return SizedBox.square(
        dimension: 16,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
        ),
      );
    }
    final themeIcon = theme.icon;
    if (data.type == ButterToastType.normal || !theme.typeIcons) {
      return themeIcon == null ? null : sized(themeIcon);
    }
    return Icon(
      switch (data.type) {
        ButterToastType.success => Icons.check_circle_rounded,
        ButterToastType.error => Icons.error_rounded,
        ButterToastType.warning => Icons.warning_rounded,
        _ => Icons.info_rounded,
      },
      size: size,
      color: color,
    );
  }
}

/// The message and description, cut to fit with "Show more", or in full
/// and scrollable with "Show less".
class _ToastText extends StatelessWidget {
  const _ToastText({
    required this.data,
    required this.pill,
    required this.style,
    required this.maxLines,
    required this.maxHeight,
    required this.expanded,
    required this.onToggle,
  });

  final ToastData data;
  final bool pill;
  final TextStyle style;
  final int maxLines;
  final double maxHeight;
  final bool expanded;
  final VoidCallback onToggle;

  static const _linkGap = 4.0;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final titleStyle = pill
        ? style
        : style.copyWith(fontWeight: FontWeight.w600);
    final descStyle = style.copyWith(
      fontSize: (style.fontSize ?? 14) - 1,
      color: style.color?.withValues(alpha: 0.72),
    );
    final linkStyle = style.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: style.color?.withValues(alpha: 0.9),
    );
    final description = data.description;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double lineHeight(TextStyle s) =>
            scaler.scale(s.fontSize ?? 14) * (s.height ?? 1.4);

        // How many lines fit in the space left, never more than maxLines.
        final linkHeight = lineHeight(linkStyle) + _linkGap;
        final room = maxHeight - linkHeight;
        final fitting = math.max(1, (room / lineHeight(style)).floor());
        final titleLines = math.min(pill ? maxLines : 2, fitting);
        final descLines = description == null
            ? 0
            : math.max(
                1,
                math.min(
                  maxLines,
                  ((room - titleLines * lineHeight(titleStyle)) /
                          lineHeight(descStyle))
                      .floor(),
                ),
              );

        bool overflows(String text, TextStyle s, int lines) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: s),
            textDirection: direction,
            textScaler: scaler,
            maxLines: lines,
          )..layout(maxWidth: width.isFinite ? width : double.infinity);
          final result = painter.didExceedMaxLines;
          painter.dispose();
          return result;
        }

        final cut =
            overflows(data.message, titleStyle, titleLines) ||
            (description != null &&
                overflows(description, descStyle, descLines));

        final link = GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: _linkGap),
            child: Text(expanded ? 'Show less' : 'Show more', style: linkStyle),
          ),
        );

        if (expanded) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: math.max(lineHeight(style), room),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.message, style: titleStyle),
                        if (description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(description, style: descStyle),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              link,
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.message,
              style: titleStyle,
              maxLines: titleLines,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  description,
                  style: descStyle,
                  maxLines: descLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (cut) link,
          ],
        );
      },
    );
  }
}

/// The filled button of a toast's action, in the toast's colours swapped.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.pill,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final bool pill;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(pill ? 14 : 7),
            ),
            child: Text(
              label,
              maxLines: 1,
              style: DefaultTextStyle.of(context).style.copyWith(
                color: foreground,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small "×" that dismisses the toast.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      // Not every app has Material localizations, such as a CupertinoApp.
      label:
          Localizations.of<MaterialLocalizations>(
            context,
            MaterialLocalizations,
          )?.closeButtonTooltip ??
          'Close',
      onTap: onPressed,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          // A 28 px target around a 16 px icon.
          child: SizedBox.square(
            dimension: 28,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
