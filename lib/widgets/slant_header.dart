import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The accent block that tops a screen: the title in leaning capitals,
/// its actions, optionally a few lines of the screen's own content, two
/// racing stripes and a bottom edge that falls away to the left.
///
/// It reaches under the status bar, and shows a back arrow whenever the
/// screen can be left.
class SlantHeader extends StatelessWidget {
  const SlantHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.child,
  });

  /// How much lower the bottom edge is on the left than on the right.
  static const slant = 22.0;
  static const barHeight = 52.0;

  final String title;

  /// Shown after the title, smaller: the month, on the services tab.
  final String? subtitle;
  final List<Widget> actions;

  /// The screen's own content inside the block, under the title.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final stripe = Transform(
      transform: Matrix4.skewX(-0.42),
      child: ColoredBox(color: c.onPrimary.withValues(alpha: 0.14)),
    );
    final titleText = Text(
      title.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 28,
        height: 1,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOn(c.onPrimary),
      child: ClipPath(
        clipper: const _SlantClipper(),
        child: ColoredBox(
          color: c.primary,
          child: Stack(
            children: [
              Positioned(
                top: -20,
                bottom: -20,
                right: 96,
                width: 16,
                child: stripe,
              ),
              Positioned(
                top: -20,
                bottom: -20,
                right: 66,
                width: 8,
                child: stripe,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  canPop ? 4 : 16,
                  top,
                  4,
                  slant + 8,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: IconButtonTheme(
                    data: IconButtonThemeData(
                      style: IconButton.styleFrom(foregroundColor: c.onPrimary),
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: c.onPrimary),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: barHeight,
                            child: Row(
                              children: [
                                if (canPop)
                                  IconButton(
                                    tooltip: MaterialLocalizations.of(context)
                                        .backButtonTooltip,
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    onPressed: () =>
                                        Navigator.maybePop(context),
                                  ),
                                if (subtitle == null)
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: titleText,
                                    ),
                                  )
                                else ...[
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 220,
                                    ),
                                    child: titleText,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      subtitle!.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                                ...actions,
                              ],
                            ),
                          ),
                          if (child != null)
                            Padding(
                              padding: EdgeInsets.only(
                                left: canPop ? 12 : 0,
                                right: 12,
                              ),
                              child: child,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [SlantHeader] as a screen's app bar, for screens that put nothing but
/// the title and actions in it.
class SlantAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SlantAppBar({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Size get preferredSize =>
      const Size.fromHeight(SlantHeader.barHeight + SlantHeader.slant + 8);

  @override
  Widget build(BuildContext context) =>
      SlantHeader(title: title, actions: actions);
}

class _SlantClipper extends CustomClipper<Path> {
  const _SlantClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - SlantHeader.slant)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_SlantClipper oldClipper) => false;
}
