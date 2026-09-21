import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/sync_status.dart';

/// Thin top banner: blue while syncing, green with a check when done.
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF22A06B);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ValueListenableBuilder<SyncPhase>(
      valueListenable: syncController,
      builder: (context, phase, _) {
        final syncing = phase == SyncPhase.syncing;
        final visible = phase != SyncPhase.idle;
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: !visible
              ? const SizedBox(width: double.infinity, height: 0)
              : Container(
                  width: double.infinity,
                  color: syncing ? _blue : _green,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (syncing)
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        syncing ? t.syncing : t.synced,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
