import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One row of a list, edge to edge with a hairline under it: something
/// leading (usually a `SkewIcon`), a title, optionally a line under it,
/// and whatever ends the row. The lists of the app are made of these
/// rather than of cards.
class RaceRow extends StatelessWidget {
  const RaceRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.below,
    this.trailing,
    this.onTap,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;

  /// Under the title in place of [subtitle], where a line of text will
  /// not do: a plate, a progress bar.
  final Widget? below;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int titleMaxLines;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: EdgeInsets.fromLTRB(16, 8, trailing == null ? 16 : 6, 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (below != null) ...[const SizedBox(height: 4), below!],
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: subtitleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: c.muted),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
