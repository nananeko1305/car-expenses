import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Leans its child to the right, the way the app's buttons, tags and
/// blocks lean. Whatever is inside leans with it, text included.
class Skewed extends StatelessWidget {
  const Skewed({super.key, this.angle = tenDegrees, required this.child});

  static const tenDegrees = 0.1745;
  static const eightDegrees = 0.1396;

  /// In radians.
  final double angle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform(
    transform: Matrix4.skewX(-angle),
    alignment: Alignment.center,
    child: child,
  );
}

/// A leaning button: filled with the accent unless [background] says
/// otherwise, or just an outline in [foreground]. The label is shown in
/// capitals. A null [onPressed] disables it.
class SkewButton extends StatelessWidget {
  const SkewButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.background,
    this.foreground,
    this.outlined = false,
    this.height = 44,
    this.fontSize = 14,
    this.elevation = 0,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final bool outlined;
  final double height;
  final double fontSize;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = foreground ?? (outlined ? c.ink : c.onPrimary);
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Skewed(
        child: Material(
          color: outlined ? Colors.transparent : (background ?? c.primary),
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: outlined ? BorderSide(color: fg, width: 2) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                // A long label shrinks to fit rather than lose its end.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: fontSize + 6, color: fg),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: fg,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small leaning outlined label, in capitals, such as "no charge".
class SkewTag extends StatelessWidget {
  const SkewTag(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.colors.muted;
    return Skewed(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: fg, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// On or off, as a leaning block with a square knob that sits right when
/// on. With [onAccent] it is drawn in the text color of an accent block,
/// for use on one. A null [onChanged] makes it read-only.
class SkewSwitch extends StatelessWidget {
  const SkewSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.onAccent = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = onAccent ? c.onPrimary : c.primary;
    final off = onAccent ? c.onPrimary : c.muted;
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Skewed(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 46,
              height: 26,
              padding: const EdgeInsets.all(2),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? on : Colors.transparent,
                border: Border.all(color: value ? on : off, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value ? (onAccent ? c.primary : c.onPrimary) : off,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A boxed row with a title, an optional line under it and a
/// [SkewSwitch]; tapping anywhere on it flips the switch.
class SkewSwitchTile extends StatelessWidget {
  const SkewSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: c.line),
    );
    return MergeSemantics(
      child: Material(
        color: Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 3, 5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                    ],
                  ),
                ),
                SkewSwitch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A screen's main action, floating over its list: a [SkewButton] with
/// the size and lift of a floating button.
class SkewFab extends StatelessWidget {
  const SkewFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SkewButton(
    label: label,
    icon: icon,
    height: 50,
    fontSize: 16,
    elevation: 4,
    onPressed: onPressed,
  );
}

/// The button that ends a form, as wide as the form lets it be.
class SkewSubmit extends StatelessWidget {
  const SkewSubmit({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.check_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    // It leans, so it needs room at both ends.
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: SkewButton(
      label: label,
      icon: icon,
      height: 52,
      fontSize: 18,
      onPressed: onPressed,
    ),
  );
}

/// A leaning block with an icon in it, to lead a row: the dark block, or
/// a tint of [color] with the icon in that color.
class SkewIcon extends StatelessWidget {
  const SkewIcon(this.icon, {super.key, this.color, this.size = 36});

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: Skewed(
        angle: Skewed.eightDegrees,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color == null ? c.ink : color!.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: size * 0.5, color: color ?? c.background),
        ),
      ),
    );
  }
}
